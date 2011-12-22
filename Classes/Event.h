
/*
     File: Event.h
 Abstract: A class to represent an event containing geographical coordinates, a time stamp, and an image with a thumbnail. Every Event has a CouchDB document.
 
  Version: 1.1
 */

#import <CouchCocoa/CouchModel.h>
#import <Foundation/Foundation.h>
@interface Event : CouchModel  {
   
}
@property (nonatomic, readonly) NSString *name;
/**< Name/Title of the project */

@property (nonatomic, copy) NSString *location;
/**< Where the project is being undertaken */

@property (nonatomic, copy) NSString *_id;
/**< project id */
/**< Gives the name of people involved in the project */


/** ProjecWithDatabase will fetch the name and location from project document
 @param Project name which is to be displayed
 @param Location is where the project is invoked */
+ (Event*) projectWithDatabase:(CouchDatabase*)database name:(NSString*)name location:(NSString *)location id:(NSString *)_id;

@end


