//
//  DBManager.h
//  testSample
//
//  Created by Mittal J. Banker on 22/09/16.
//  Copyright © 2016 digicorp. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <sqlite3.h>
#import "FMDB.h"
#define TBL_USERS @"TABLE_USERS"
typedef enum {
    OprationInToLiveTable          = 0,
    OprationInToLocalTable         = 1
} OprationType;


typedef void (^CompletionHandler)(NSMutableArray *result);
typedef void (^QueryCompletionHandler)(BOOL success);;

@interface DBManager : NSObject
{
NSString *databasePath;
}

+(DBManager*)getSharedInstance;
-(BOOL)createDB;
-(BOOL) saveData:(NSString*)registerNumber name:(NSString*)name
      department:(NSString*)department year:(NSString*)year;
-(NSArray*) findByRegisterNumber:(NSString*)registerNumber;
-(NSMutableArray*)selectData;
- (BOOL)deleteData:(NSString*)registerNumber;
-(void)insertTableFromType:(NSMutableArray*)dbSkleton andOprationType:(OprationType)opration  andHandler:(QueryCompletionHandler)handler;
@end
