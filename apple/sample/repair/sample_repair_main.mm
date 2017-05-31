//
//  sample_repair_main.m
//  WCDB
//
//  Created by sanhuazhang on 2017/5/31.
//  Copyright © 2017年 sanhuazhang. All rights reserved.
//

#import "sample_repair_main.h"
#import "WCTSampleRepair.h"

void sample_repair_main(NSString* baseDirectory)
{
    NSString* className = NSStringFromClass(WCTSampleRepair.class);
    NSString* path = [baseDirectory stringByAppendingPathComponent:className];
    NSString* recoverPath = [path stringByAppendingString:@"_recover"];
    NSString* tableName = className; 
    WCTDatabase* database = [[WCTDatabase alloc] initWithPath:path];
    [database close:^{
        [database removeFilesWithError:nil];
    }];
    WCTDatabase* recover = [[WCTDatabase alloc] initWithPath:recoverPath];
    [recover close:^{
        [recover removeFilesWithError:nil];
    }];
    
    //prepare
    {
        [database createTableAndIndexesOfName:tableName
                                    withClass:WCTSampleRepair.class];
        for (int i = 0; i < 10; ++i) {
            WCTSampleRepair* object = [[WCTSampleRepair alloc] init];
            object.identifier = i;
            object.content = [NSString stringWithFormat:@"%d", i];
            [database insertObject:object
                              into:tableName];
        }
        NSLog(@"The count of objects before: %lu", [database getAllObjectsOfClass:WCTSampleRepair.class fromTable:tableName].count);
    }
    
    NSString* password = @"sample_password";
    NSData* cipher = [password dataUsingEncoding:NSASCIIStringEncoding];

    //backup
    {
        BOOL ret = [database backupWithCipher:cipher];   
    }
    
    //get page size
    int pageSize;
    //get page size from origin database.
    //Since page size never change unless you can call "PRAGMA page_size=NewPageSize" to set it. You have no need to get the page size like this. Instead, you can hardcode it.
    {
        @autoreleasepool {
            WCTStatement* statement = [database prepare:WCDB::StatementPragma().pragma(WCDB::Pragma::PageSize)];
            [statement step];
            NSNumber* value = (NSNumber*)[statement getValueAtIndex:0];
            pageSize = value.intValue;
            statement = nil;
        }
    }
    
    //do something
    //corrupt
    {
        [database close:^{
            FILE* file = fopen(path.UTF8String, "rb+");
            unsigned char* zeroPage = new unsigned char[100];
            memset(zeroPage, 0, 100);
            fwrite(zeroPage, 100, 1, file);
            fclose(file);
        }];
        
        NSLog(@"The count of objects corrupted: %lu", [database getAllObjectsOfClass:WCTSampleRepair.class fromTable:tableName].count);
    }
    
    //repair
    {
        //Since recovering is a long time operation, you'd better call it in sub-thread.
        //dispatch_async(DISPATCH_QUEUE_PRIORITY_BACKGROUND, ^{
        WCTDatabase* recover = [[WCTDatabase alloc] initWithPath:recoverPath];
        [database close:^{
            [recover recoverFromPath:path withPageSize:pageSize withCipher:cipher];
        }];
        NSLog(@"The count of objects repaired: %lu", [recover getAllObjectsOfClass:WCTSampleRepair.class fromTable:tableName].count);
    }

}