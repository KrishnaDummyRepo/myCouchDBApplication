
/*
     File: LocationsAppDelegate.m
 Abstract: Application delegate to set up Couchbase Mobile and configure the view and navigation controllers.
  Version: 1.1
 */

#import "LocationsAppDelegate.h"
#import "EventDetailViewController.h"

@class CouchQuery;
@implementation LocationsAppDelegate

@synthesize window;
@synthesize rootViewController;
@synthesize navigationController;
@synthesize server;
@synthesize database;
@synthesize viewToWaitForServer;


#pragma mark -
#pragma mark Application lifecycle

-(void) callTheHomeViewController {
    
    EventDetailViewController *tempViewController = [[EventDetailViewController alloc]initWithNibName:@"EventDetailViewController" bundle:[NSBundle mainBundle]];
    self.rootViewController = tempViewController;
    [tempViewController release];
    UINavigationController *temp = [[UINavigationController alloc]initWithRootViewController:self.rootViewController];
    self.navigationController = temp;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [temp release];
}




- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    CouchbaseMobile* cb = [[CouchbaseMobile alloc] init];
    cb.delegate = self;
    BOOL isCBStarted =  [cb start];
	if (!isCBStarted) {
        NSLog(@"sorry!----> cdnt start");
    }    
    EventDetailViewController *tempViewController = [[EventDetailViewController alloc]initWithNibName:@"EventDetailViewController" bundle:[NSBundle mainBundle]];
    self.rootViewController = tempViewController;
    
    [tempViewController release];
    
    UINavigationController *temp = [[UINavigationController alloc]initWithRootViewController:self.rootViewController];
    self.navigationController = temp;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [temp release];
    
    self.window.rootViewController = self.navigationController;
    
    UIImageView *tempImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 748, 1024)];
    tempImageView.image = [UIImage imageNamed:@"source1.png"];
    self.viewToWaitForServer = tempImageView;
    [self.window addSubview:self.viewToWaitForServer];
    [tempImageView release];
    [self.window makeKeyAndVisible]; 
    return YES;
}
-(void) removeSplash {
    
    if (self.viewToWaitForServer) {
        [self.viewToWaitForServer removeFromSuperview];
        self.viewToWaitForServer = nil;
    }
}
// This is the CouchbaseDelegate method called when the database starts up:
-(void)couchbaseMobile:(CouchbaseMobile*)cb didStart:(NSURL *)serverURL {
    
    if(!self.database) {
        if (self.server == nil) {
            
            /** Do this the first time the server starts, i.e. not after a wake-from-bg: */
            self.server = [[[CouchServer alloc] initWithURL: serverURL] autorelease];               /**< listning Server */
            /** database name from which data is to be retrieved */
            self.database = [self.server databaseNamed: @"big-sample-set"];
            RESTOperation* op = [self.database create];
            [op start];
            
            /**<412 = Conflict; just means DB already exists */
            if (![op wait] && op.httpStatus != 412) {                               
                NSLog(@"Couchbase couldn't start!");// Couchbase couldn't start!
            }
            
            else if(op.httpStatus == 0 || op.httpStatus >=300) {
                //Connection Timeout! Error
            }
            
        }
        NSArray *array = [self.navigationController viewControllers];
         EventDetailViewController *controller = nil;
        if (array != nil && [array count] > 0) {
            controller = (EventDetailViewController *)[array objectAtIndex:0];
        }
        
        if (controller != nil && [controller isKindOfClass:[EventDetailViewController class]]) {
            [controller loadProjectList];
            [self removeSplash];            
        }
    }
    self.database.tracksChanges = YES;
}




-(void)couchbaseMobile:(CouchbaseMobile*)couchbase failedToStart:(NSError*)error {
    NSLog(@"server error");    
}



- (void)applicationDidEnterBackground:(UIApplication *)application {
    
    self.database.tracksChanges = NO;                                                                  /**< Turn off the _changes watcher:*/
    //[RESTOperation wait: self.database.activeOperations]; /**< Make sure all transactions complete, because going into the background will close down the CouchDB server:*/
}


- (void)applicationWillTerminate:(UIApplication *)application {
    self.database.tracksActiveOperations = YES;
    //[RESTOperation wait: self.database.activeOperations];
}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    [navigationController release];
    [window release];
    [rootViewController release];
    [database release];
    [server release];
    [viewToWaitForServer release];
    [super dealloc];
}


@end
