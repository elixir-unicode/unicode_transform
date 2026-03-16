/*
 * utransform NIF — wraps ICU4C's utrans API for Elixir.
 *
 * Exposes two functions:
 *   transform(id, text, direction) -> {:ok, binary} | {:error, binary}
 *   available_ids()                -> [binary]
 */

#ifdef DARWIN
#define U_HIDE_DRAFT_API 1
#define U_DISABLE_RENAMING 1
#endif

#include "erl_nif.h"
#include "unicode/utrans.h"
#include "unicode/ustring.h"
#include "unicode/uenum.h"
#include "unicode/utypes.h"
#include <string.h>
#include <stdlib.h>

/* Atoms cached at load time */
static ERL_NIF_TERM ATOM_OK;
static ERL_NIF_TERM ATOM_ERROR;

/* --- helpers ------------------------------------------------------------- */

/*
 * Convert a UTF-8 ErlNifBinary to a newly allocated UChar* buffer.
 * Caller must free the returned pointer with enif_free().
 * On failure, returns NULL and sets *out_len to 0.
 */
static UChar*
utf8_to_uchar(const unsigned char* src, int32_t src_len, int32_t* out_len)
{
    UErrorCode status = U_ZERO_ERROR;
    int32_t uchar_len = 0;

    /* Pre-flight to get required length */
    u_strFromUTF8(NULL, 0, &uchar_len, (const char*)src, src_len, &status);

    if (status != U_BUFFER_OVERFLOW_ERROR && U_FAILURE(status)) {
        *out_len = 0;
        return NULL;
    }

    status = U_ZERO_ERROR;
    UChar* buf = (UChar*)enif_alloc(sizeof(UChar) * (uchar_len + 1));

    if (buf == NULL) {
        *out_len = 0;
        return NULL;
    }

    u_strFromUTF8(buf, uchar_len + 1, &uchar_len, (const char*)src, src_len, &status);

    if (U_FAILURE(status)) {
        enif_free(buf);
        *out_len = 0;
        return NULL;
    }

    *out_len = uchar_len;
    return buf;
}

/*
 * Convert a UChar* buffer to a UTF-8 ERL_NIF_TERM binary.
 */
static ERL_NIF_TERM
uchar_to_utf8_binary(ErlNifEnv* env, const UChar* src, int32_t src_len)
{
    UErrorCode status = U_ZERO_ERROR;
    int32_t utf8_len = 0;

    /* Pre-flight */
    u_strToUTF8(NULL, 0, &utf8_len, src, src_len, &status);

    if (status != U_BUFFER_OVERFLOW_ERROR && U_FAILURE(status)) {
        return enif_make_binary(env, &(ErlNifBinary){.size = 0});
    }

    status = U_ZERO_ERROR;
    ErlNifBinary out;

    if (!enif_alloc_binary(utf8_len, &out)) {
        return enif_make_binary(env, &(ErlNifBinary){.size = 0});
    }

    u_strToUTF8((char*)out.data, utf8_len, &utf8_len, src, src_len, &status);

    if (U_FAILURE(status)) {
        enif_release_binary(&out);
        return enif_make_binary(env, &(ErlNifBinary){.size = 0});
    }

    out.size = (size_t)utf8_len;
    return enif_make_binary(env, &out);
}

static ERL_NIF_TERM
make_error(ErlNifEnv* env, const char* reason)
{
    ErlNifBinary bin;
    size_t len = strlen(reason);

    if (!enif_alloc_binary(len, &bin)) {
        return enif_make_tuple2(env, ATOM_ERROR,
            enif_make_string(env, reason, ERL_NIF_LATIN1));
    }

    memcpy(bin.data, reason, len);
    return enif_make_tuple2(env, ATOM_ERROR, enif_make_binary(env, &bin));
}

/* --- NIF functions ------------------------------------------------------- */

/*
 * transform(id :: binary, text :: binary, direction :: integer) ->
 *   {:ok, binary} | {:error, binary}
 *
 * direction: 0 = UTRANS_FORWARD, 1 = UTRANS_REVERSE
 */
static ERL_NIF_TERM
nif_transform(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    ErlNifBinary id_bin, text_bin;
    int direction;

    if (!enif_inspect_binary(env, argv[0], &id_bin) ||
        !enif_inspect_binary(env, argv[1], &text_bin) ||
        !enif_get_int(env, argv[2], &direction)) {
        return enif_make_badarg(env);
    }

    if (direction != UTRANS_FORWARD && direction != UTRANS_REVERSE) {
        return make_error(env, "invalid direction");
    }

    /* Convert transform ID from UTF-8 to UChar */
    int32_t id_ulen = 0;
    UChar* id_uchar = utf8_to_uchar(id_bin.data, (int32_t)id_bin.size, &id_ulen);

    if (id_uchar == NULL) {
        return make_error(env, "failed to convert transform ID to UTF-16");
    }

    /* Open the transliterator */
    UErrorCode status = U_ZERO_ERROR;
    UParseError parse_error;

    UTransliterator* trans = utrans_openU(
        id_uchar, id_ulen,
        (UTransDirection)direction,
        NULL, -1,           /* no custom rules */
        &parse_error,
        &status
    );

    enif_free(id_uchar);

    if (U_FAILURE(status) || trans == NULL) {
        char err_buf[256];
        snprintf(err_buf, sizeof(err_buf), "utrans_openU failed: %s",
                 u_errorName(status));
        return make_error(env, err_buf);
    }

    /* Handle empty input */
    if (text_bin.size == 0) {
        utrans_close(trans);
        ErlNifBinary empty;
        enif_alloc_binary(0, &empty);
        return enif_make_tuple2(env, ATOM_OK, enif_make_binary(env, &empty));
    }

    /* Convert input text from UTF-8 to UChar */
    int32_t text_ulen = 0;
    UChar* text_uchar = utf8_to_uchar(text_bin.data, (int32_t)text_bin.size, &text_ulen);

    if (text_uchar == NULL) {
        utrans_close(trans);
        return make_error(env, "failed to convert input text to UTF-16");
    }

    /*
     * Allocate a mutable buffer for utrans_transUChars.
     * The transform can expand text (e.g. NFD, ligature expansion),
     * so we allocate generously: 4x input + 256 minimum.
     */
    int32_t buf_capacity = text_ulen * 4;

    if (buf_capacity < 256) {
        buf_capacity = 256;
    }

    UChar* buf = (UChar*)enif_alloc(sizeof(UChar) * (buf_capacity + 1));

    if (buf == NULL) {
        enif_free(text_uchar);
        utrans_close(trans);
        return make_error(env, "memory allocation failed");
    }

    /* Copy input into the mutable buffer */
    memcpy(buf, text_uchar, sizeof(UChar) * text_ulen);
    buf[text_ulen] = 0;
    enif_free(text_uchar);

    int32_t result_len = text_ulen;
    int32_t limit = text_ulen;

    status = U_ZERO_ERROR;
    utrans_transUChars(trans, buf, &result_len, buf_capacity, 0, &limit, &status);

    /* If buffer was too small, retry with the required size */
    if (status == U_BUFFER_OVERFLOW_ERROR) {
        enif_free(buf);

        buf_capacity = result_len + 64;
        buf = (UChar*)enif_alloc(sizeof(UChar) * (buf_capacity + 1));

        if (buf == NULL) {
            utrans_close(trans);
            return make_error(env, "memory allocation failed on retry");
        }

        /* Re-convert from original input */
        text_uchar = utf8_to_uchar(text_bin.data, (int32_t)text_bin.size, &text_ulen);

        if (text_uchar == NULL) {
            enif_free(buf);
            utrans_close(trans);
            return make_error(env, "failed to re-convert input on retry");
        }

        memcpy(buf, text_uchar, sizeof(UChar) * text_ulen);
        buf[text_ulen] = 0;
        enif_free(text_uchar);

        result_len = text_ulen;
        limit = text_ulen;
        status = U_ZERO_ERROR;

        utrans_transUChars(trans, buf, &result_len, buf_capacity, 0, &limit, &status);
    }

    utrans_close(trans);

    if (U_FAILURE(status)) {
        char err_buf[256];
        snprintf(err_buf, sizeof(err_buf), "utrans_transUChars failed: %s",
                 u_errorName(status));
        enif_free(buf);
        return make_error(env, err_buf);
    }

    /* Convert result back to UTF-8 */
    ERL_NIF_TERM result_term = uchar_to_utf8_binary(env, buf, result_len);
    enif_free(buf);

    return enif_make_tuple2(env, ATOM_OK, result_term);
}

/*
 * available_ids() -> [binary]
 *
 * Returns a list of all registered ICU transliterator IDs.
 */
static ERL_NIF_TERM
nif_available_ids(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
    UErrorCode status = U_ZERO_ERROR;
    UEnumeration* en = utrans_openIDs(&status);

    if (U_FAILURE(status) || en == NULL) {
        return enif_make_list(env, 0);
    }

    ERL_NIF_TERM list = enif_make_list(env, 0);
    const char* id;
    int32_t id_len;

    while ((id = uenum_next(en, &id_len, &status)) != NULL) {
        if (U_FAILURE(status)) {
            break;
        }

        ErlNifBinary bin;

        if (enif_alloc_binary((size_t)id_len, &bin)) {
            memcpy(bin.data, id, (size_t)id_len);
            list = enif_make_list_cell(env, enif_make_binary(env, &bin), list);
        }
    }

    uenum_close(en);

    /* Reverse the list to get original order */
    ERL_NIF_TERM reversed = enif_make_list(env, 0);
    ERL_NIF_TERM head;

    while (enif_get_list_cell(env, list, &head, &list)) {
        reversed = enif_make_list_cell(env, head, reversed);
    }

    return reversed;
}

/* --- lifecycle ----------------------------------------------------------- */

static int
on_load(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM info)
{
    ATOM_OK = enif_make_atom(env, "ok");
    ATOM_ERROR = enif_make_atom(env, "error");
    *priv_data = NULL;
    return 0;
}

static void
on_unload(ErlNifEnv* env, void* priv_data)
{
    /* Nothing to clean up */
}

static int
on_reload(ErlNifEnv* env, void** priv_data, ERL_NIF_TERM info)
{
    return 0;
}

static int
on_upgrade(ErlNifEnv* env, void** priv_data, void** old_data, ERL_NIF_TERM info)
{
    return on_load(env, priv_data, info);
}

/* --- NIF registration ---------------------------------------------------- */

static ErlNifFunc nif_funcs[] =
{
    {"transform", 3, nif_transform},
    {"available_ids", 0, nif_available_ids}
};

ERL_NIF_INIT(Elixir.Unicode.Transform.Nif, nif_funcs,
             &on_load, &on_reload, &on_upgrade, &on_unload)
