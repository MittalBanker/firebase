//
//  DBManager.m
//  testSample
//
//  Created by Mittal J. Banker on 22/09/16.
//  Copyright © 2016 digicorp. All rights reserved.
//

#import "DBManager.h"
#import "User.h"
@implementation DBManager

static DBManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

+(DBManager*)getSharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}


- (NSString *) getDBPath
{
    //Search for standard documents using NSSearchPathForDirectoriesInDomains
    //First Param = Searching the documents directory
    //Second Param = Searching the Users directory and not the System
    //Expand any tildes and identify home directories.
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    //NSLog(@"dbpath : %@",documentsDir);
    return [documentsDir stringByAppendingPathComponent:@"Users.sqlite"];
}

-(BOOL)createDB{
    //Using NSFileManager we can perform many file system operations.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    
    databasePath = [self getDBPath];
    BOOL success = [fileManager fileExistsAtPath:databasePath];
    
    if(!success) {
        
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Users.sqlite"];
        success = [fileManager copyItemAtPath:defaultDBPath toPath:databasePath error:&error];
        
        if (!success)
            NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
    return success;
}


#pragma mark  Insert Table Statement

-(void)insertTableFromType:(NSMutableArray*)dbSkleton andOprationType:(OprationType)opration  andHandler:(QueryCompletionHandler)handler{
            [self insertOrReplaceInBatchIntoTable:TBL_USERS andRecords:dbSkleton withCompletionHandler:^(BOOL success) {
     
            }];

    handler(TRUE);
}

-(void)insertOrReplaceInBatchIntoTable:(NSString*)tableName andRecords:(NSArray*)records withCompletionHandler:(QueryCompletionHandler)handler
{
    if ([records count] > 0) {
        NSMutableString *query =[[NSMutableString alloc]init];
        NSMutableString *queryValues =[[NSMutableString alloc]init];
        
        NSDictionary *columnDictinary = [records objectAtIndex:0];
        for (NSString *column in columnDictinary) {
            [query appendString:[NSString stringWithFormat:@"%@",column]];
            [query appendString:[NSString stringWithFormat:@","]];
            [queryValues appendString:[NSString stringWithFormat:@":%@",column]];
            [queryValues appendString:[NSString stringWithFormat:@","]];
        }
        
        // remove last comma from query
        
        if (query.length > 0) {
            [query deleteCharactersInRange:NSMakeRange([query length]-1, 1)];
        }
        if (queryValues.length > 0) {
            [queryValues deleteCharactersInRange:NSMakeRange([queryValues length]-1, 1)];
        }
        
        
        NSString *insertQuery = [NSString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@) VALUES (%@)",tableName,query,queryValues];
        
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:databasePath];
        [queue inDatabase:^(FMDatabase *db) {
            for (int index = 0; index < records.count; index++) {
                NSDictionary *recordDictinary = [records objectAtIndex:index];
                
                [db executeUpdate:insertQuery withParameterDictionary:recordDictinary];
            }
            
        }];
        [queue close];
    }
    NSLog(@"data path %@",databasePath);
}

- (BOOL) saveData:(NSString*)registerNumber name:(NSString*)name
       department:(NSString*)department year:(NSString*)year;
{
    BOOL success;
    const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into studentsDetail (regno,name, department, year) values                                (\"%ld\",\"%@\", \"%@\", \"%@\")",(long)[registerNumber integerValue],name, department, year];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            success =  YES;
        }
        else {
            success = NO;
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    return success;
}


-(NSMutableArray*)selectData{
    const char *dbpath = [databasePath UTF8String];
    NSMutableArray *retval = [NSMutableArray array];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
        
    {
        NSString *query = [NSString stringWithFormat:@"select * from %@",TBL_USERS];
        sqlite3_stmt *compiledStmt;
        if (sqlite3_prepare_v2(database, [query UTF8String], -1, &compiledStmt, nil) == SQLITE_OK) {
            while (sqlite3_step(compiledStmt) == SQLITE_ROW) {
                User *v = [[User alloc] initFromCompiledStatement:compiledStmt];
                [retval addObject:v];
            }
            sqlite3_finalize(compiledStmt);
        }
        return retval;
        
    }
    
    return nil;
}

- (BOOL)deleteData:(NSString*)registerNumber
{


    
      const char *dbpath = [databasePath UTF8String];
    if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
        
        NSString *sql = [NSString stringWithFormat:@"delete from studentsDetail where regno =%d",[registerNumber intValue]];
        
        const char *del_stmt = [sql UTF8String];
        
        sqlite3_prepare_v2(database, del_stmt, -1, & statement, NULL);
        if(SQLITE_DONE != sqlite3_step(statement))
        {
           NSLog( @"Error: %s", sqlite3_errmsg(database) );
            
        }
        else
        {
             return YES;
            NSLog(@"Deleted chart segment successfully !");
            
        }
        sqlite3_finalize(statement);
        sqlite3_close(database);
        
        
    }
      return NO;
}

@end
