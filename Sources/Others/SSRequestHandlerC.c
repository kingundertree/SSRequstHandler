//
//  SSRequestHandlerC.h
//  AFNetworking
//
//  Created by ixiazer on 2020/3/11.
//

#include "SSRequestHandlerC.h"
#include <string.h>
#include <stdlib.h>
#include <CommonCrypto/CommonDigest.h>

const char* md5FromString(const char *value) {
    if (!value || strlen(value) == 0) {
        return NULL;
    }
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    char *outputString = malloc(CC_MD5_DIGEST_LENGTH * 2 + 1);
    char *index = outputString;
    
    for(int count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        sprintf(index, "%02x", outputBuffer[count]);
        index += 2;
    }
    
    return outputString;
}
