//
//  main.cpp
//  MD5Pheonix
//
//  Created by Ebrahim Alhaddad on 11/15/18.
//  Copyright © 2018 Ebrahim Alhaddad. All rights reserved.
//

#include <iostream>
#include "md5.h"
#include <chrono>

int main(int argc, const char * argv[]) {
    
    //Create Input
    unsigned inputChar = 'F';
    
    unsigned char testStr[64];
    for(int i = 0; i < 64; i++){
        testStr[i] = inputChar;
    }
    //std::cout << "input:" << testStr << std::endl;
    //md5 Test Run
    md5 hasher;
    unsigned char* test = (unsigned char*)testStr;
    hasher.md5Launch(test);
    hasher.md5Timed(test);
    
    return 0;
}
