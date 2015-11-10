//
//  Snappy-ObjC.m
//  Snappy for Objective-C
//
//  Created by Mathieu D'Amours on 5/18/13.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2013 Mathieu D'Amours
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of
//  this software and associated documentation files (the "Software"), to deal in
//  the Software without restriction, including without limitation the rights to
//  use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
//  the Software, and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
//  FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//  COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
//  IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
//  CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "snappy.h"
#import "Snappy-ObjC.h"

#ifdef SNAPPY_NO_PREFIX
#define mn(_name_) _name_
#else
#define mn(_name_) snappy_ ## _name_
#endif

@implementation NSData (Snappy)

- (NSData *) mn(compressedData) {
  struct snappy_env env;
  if(snappy_init_env(&env) != 0) {
    return nil;
  }
  size_t clen = snappy_max_compressed_length(self.length);
  if(clen == 0) {
    return nil;
  }
  char *buffer = malloc(clen);
  if(snappy_compress(&env, self.bytes, self.length, buffer, &clen) != 0) {
    snappy_free_env(&env);
    return nil;
  }
  NSData * data = [NSData dataWithBytes:buffer length:clen];
  snappy_free_env(&env);
  return data;
}

- (NSData *) mn(decompressedData) {
  size_t ulen;
  snappy_uncompressed_length(self.bytes, self.length, &ulen);
  char *buffer = malloc(ulen);
  assert(snappy_uncompress(self.bytes, self.length, buffer) == 0);
  return [NSData dataWithBytesNoCopy:buffer length:ulen];
}

- (NSString *) mn(decompressedString) {
  return [[NSString alloc] initWithData:[self mn(decompressedData)]
                               encoding:NSUTF8StringEncoding];
}

@end

@implementation NSString (Snappy)

- (NSData *) mn(compressedString) {
  return [[self dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:NO] mn(compressedData)];
}

@end
