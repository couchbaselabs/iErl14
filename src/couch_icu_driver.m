/*

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License. You may obtain a copy of the
License at

  http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied. See the License for the
specific language governing permissions and limitations under the License.

*/

// This file is the C port driver for Erlang. It provides a low overhead
// means of calling into C code, however coding errors in this module can
// crash the entire Erlang server.

#define U_HIDE_DRAFT_API 1
#define U_DISABLE_RENAMING 1


#include "erl_driver.h"
#include "unicode/utypes.h"
#include "unicode/uiter.h"
#include "unicode/ucol.h"
#include "unicode/urename.h"
#ifndef WIN32
#include <string.h> // for memcpy
#endif

typedef struct {
    ErlDrvPort port;
} couch_drv_data;

static void couch_drv_stop(ErlDrvData data)
{
	//driver_free((char*)data);
}

static ErlDrvData couch_drv_start(ErlDrvPort port, char *buff)
{
//	couch_drv_data* pData = (couch_drv_data*)driver_alloc(sizeof(couch_drv_data));
//
  //  if (pData == NULL)
    //    return ERL_DRV_ERROR_GENERAL;

    //pData->port = port;

    return NULL;//(ErlDrvData)pData;
}

static int return_control_result(void* pLocalResult, int localLen, char **ppRetBuf, int returnLen)
{
    if (*ppRetBuf == NULL || localLen > returnLen) {
        *ppRetBuf = (char*)driver_alloc_binary(localLen);
        if(*ppRetBuf == NULL) {
            return -1;
        }
    }
    memcpy(*ppRetBuf, pLocalResult, localLen);
    return localLen;
}

static int couch_drv_control(ErlDrvData drv_data, unsigned int command, char *pBuf,
             int bufLen, char **rbuf, int rlen)
{
	NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    switch(command) {
    case 0: // COLLATE
    case 1: // COLLATE_NO_CASE:
        {
		int32_t length;
		char response;
		NSString* str_a;
		NSString* str_b;	
		NSComparisonResult collResult;
        // 2 strings are in the buffer, consecutively
        // The strings begin first with a 32 bit integer byte length, then the actual
        // string bytes follow.

        // first 32bits are the length
        memcpy(&length, pBuf, sizeof(length));
        pBuf += sizeof(length);
		str_a = [[NSString alloc] initWithData:[[NSData alloc] initWithBytes:pBuf length:length]
									  encoding:NSUTF8StringEncoding];
			
        // point the iterator at it.
        //uiter_setUTF8(&iterA, pBuf, length);

        pBuf += length; // now on to string b

        // first 32bits are the length
        memcpy(&length, pBuf, sizeof(length));
        pBuf += sizeof(length);
			str_b = [[NSString alloc] initWithData:[[NSData alloc] initWithBytes:pBuf length:length] 
										  encoding:NSUTF8StringEncoding];
			
        //uiter_setUTF8(&iterB, pBuf, length);

        if (command == 0) // COLLATE
			collResult = [str_a localizedCompare:str_b];
        else              // COLLATE_NO_CASE
			collResult = [str_a localizedCaseInsensitiveCompare:str_b];

        if (collResult == NSOrderedAscending)
          response = 0; //lt
        else if (collResult == NSOrderedDescending)
          response = 2; //gt
        else
          response = 1; //eq (NSOrderedSame)
		[pool release];
			
        return return_control_result(&response, sizeof(response), rbuf, rlen);
        }
	[pool release];
    default:
        return -1;
    }
}

ErlDrvEntry couch_driver_entry = {
        NULL,               /* F_PTR init, N/A */
        couch_drv_start,    /* L_PTR start, called when port is opened */
        couch_drv_stop,     /* F_PTR stop, called when port is closed */
        NULL,               /* F_PTR output, called when erlang has sent */
        NULL,               /* F_PTR ready_input, called when input descriptor ready */
        NULL,               /* F_PTR ready_output, called when output descriptor ready */
        "couch_icu_driver", /* char *driver_name, the argument to open_port */
        NULL,               /* F_PTR finish, called when unloaded */
        NULL,               /* Not used */
        couch_drv_control,  /* F_PTR control, port_command callback */
        NULL,               /* F_PTR timeout, reserved */
        NULL,               /* F_PTR outputv, reserved */
        NULL,               /* F_PTR ready_async */
        NULL,               /* F_PTR flush */
        NULL,               /* F_PTR call */
        NULL,               /* F_PTR event */
        ERL_DRV_EXTENDED_MARKER,
        ERL_DRV_EXTENDED_MAJOR_VERSION,
        ERL_DRV_EXTENDED_MINOR_VERSION,
        ERL_DRV_FLAG_USE_PORT_LOCKING,
        NULL,               /* Reserved -- Used by emulator internally */
        NULL,               /* F_PTR process_exit */
};

