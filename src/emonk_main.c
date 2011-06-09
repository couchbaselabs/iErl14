#include <string.h>

#include "erl_nif.h"

#include "alias.h"

#define GC_THRESHOLD 10485760 // 10 MiB
#define MAX_BYTES 8388608
#define MAX_MALLOC_BYTES 8388608
#define MAX_WORKERS 64

/* Stripped down -- Sans-Javascript patch */

typedef struct state_t* state_ptr;

static int
load(ErlNifEnv* env, void** priv, ENTERM load_info)
{
    return 0;
}

static void
unload(ErlNifEnv* env, void* priv)
{
	
}

static ENTERM
create_ctx(ErlNifEnv* env, int argc, CENTERM argv[])
{
	return NULL;
}

static ENTERM
eval(ErlNifEnv* env, int argc, CENTERM argv[])
{
    return enif_make_badarg(env);
}

static ENTERM
call(ErlNifEnv* env, int argc, CENTERM argv[])
{
	return enif_make_badarg(env);
}

static ENTERM
send(ErlNifEnv* env, int argc, CENTERM argv[])
{
	return enif_make_badarg(env);
}

static ErlNifFunc nif_funcs[] = {
    {"create_ctx", 1, create_ctx},
    {"eval", 4, eval},
    {"call", 5, call},
    {"send", 2, send}
};

ERL_NIF_INIT(emonk, nif_funcs, &load, NULL, NULL, unload);

