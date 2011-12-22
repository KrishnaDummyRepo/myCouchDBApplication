
/*
     File: Event.m
 Abstract: A class to represent an event containing geographical coordinates, a time stamp, and an image with a thumbnail. Every Event has a CouchDB document.
 
  Version: 1.1
 */

#import "Event.h"

#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/RESTBody.h>




@implementation Event
@synthesize _id;
@synthesize location;

-(void)dealloc {
    [_id release];
    [location release];
    [super dealloc];
    
}
/** to fetch the data related to project from database 
 @param name depicting the name of the project
 @param location tells where the project is going on
 @param _id relates to the project Id */
+ (Event*) projectWithDatabase:(CouchDatabase*)database name:(NSString*)name location:(NSString *)location id:(NSString *)_id {
    NSDictionary* properties = [NSDictionary dictionaryWithObjectsAndKeys:
                                name, @"name",
                                location, @"location",
                                _id, @"_id",
                                nil];
    CouchDocument* document = [[database untitledDocument] retain];
    RESTOperation* op = [document putProperties: properties];
    if (![op wait]) {
        //Creating Event document failed
        [document release];
        return nil;
    }
    return (Event*)[self modelForDocument:[document autorelease]];
}


/**< fetching the required fields from the database name, location, _id etc */

- (NSString*) name {
    NSString* projectName = [self getValueOfProperty: @"name"];
    return projectName;
}

- (NSString*) location {
    NSString* locName = [self getValueOfProperty: @"location"];
    return locName;
}
-(NSString *) _id {
    NSString* _idProject = [self getValueOfProperty: @"_id"];
    return _idProject;
    
}
@end