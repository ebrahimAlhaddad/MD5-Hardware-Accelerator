//
//  md5.h
//  md5Suicide
//
//  Created by Ebrahim Alhaddad on 11/12/18.
//  Copyright © 2018 Ebrahim Alhaddad. All rights reserved.
//
#include <iostream>
#include <string>
//context struct
typedef struct
{
    /** state (ABCD) */
    unsigned int state[4];
    
    /** number of bits, modulo 2^64 (lsb first) */
    unsigned int count[2];
    
    /** input buffer */
    unsigned char buffer[64];
} MD5_CTX;

class md5{
public:
    //constructor
    md5();
    //string decoder
    //len->length of input array
    void Decode (unsigned char *input,
                 unsigned int len);
    //string encoder
    //len->length of output array
    void Encode (unsigned char* output,
                 unsigned int *input,
                 unsigned int len);
    
    //rounds
    void md5Round1(unsigned int state[4]);
    void md5Round2(unsigned int state[4]);
    void md5Round3(unsigned int state[4]);
    void md5Round4(unsigned int state[4]);
    
    //md5 processor
    void md5Launch(unsigned char* inText);
    void md5Timed(unsigned char* inText);
    //context member variable
    MD5_CTX* context;
    //decoded message(64char to 16int)
    unsigned int x[16];
    //final hash digest in char
    unsigned char digest[16];
};
