
/*
     File: LocationsAppDelegate.h
 Abstract: Application delegate to set up the Core Data stack and configure the view and navigation controllers.
  Version: 1.1
 */

#import <Couchbase/CouchbaseMobile.h>
#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/RESTBody.h>
#import <UIKit/UIKit.h>

@class EventDetailViewController, CouchServer;

@interface LocationsAppDelegate : NSObject <UIApplicationDelegate, CouchbaseDelegate> {
    
    UIWindow *window;
    UINavigationController *navigationController;
    CouchDatabase* database;
    UIImageView *viewToWaitForServer;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) EventDetailViewController *rootViewController;
@property (nonatomic, retain) UINavigationController *navigationController;
@property (nonatomic, retain) CouchServer *server;
@property (nonatomic, retain) CouchDatabase *database;
@property (nonatomic,retain)UIImageView *viewToWaitForServer;


@end
