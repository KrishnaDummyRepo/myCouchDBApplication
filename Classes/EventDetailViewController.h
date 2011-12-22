
/*
     File: EventDetailViewController.h
 Abstract: The table view controller responsible for displaying the time, coordinates, and photo of an event, and allowing the user to select a photo for the event, or delete the existing photo.
 
  Version: 1.1
 */
#import <CouchCocoa/CouchUITableSource.h>
#import "Event.h"

@class CouchDatabase, CouchPersistentReplication;


@interface EventDetailViewController : UIViewController <UITextFieldDelegate,UIApplicationDelegate>{
	
    Event *event;
    UITableView *projectListTableView;
    /**< password to login */
    NSMutableArray *projectArray;
    CouchPersistentReplication* _pull;
    CouchPersistentReplication* _push;
    CouchDatabase *database;	    
    UIProgressView *progressBar;
    UITextField *textField;
    UITextField *passwrdText;
    UIImageView *viewToWaitForServer;
    BOOL isErrorTimeOut;
    UITextField *userTextField;
}
@property (nonatomic, retain) IBOutlet UITextField *userTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwrdText;
@property (nonatomic, retain) IBOutlet UITextField *textField;
@property (nonatomic, retain) NSMutableArray *projectArray;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) IBOutlet UITableView *projectListTableView; 
- (IBAction)syncBtnAction:(id)sender;

@property (nonatomic, retain) CouchDatabase *database;	    
@property (nonatomic, retain) IBOutlet UIProgressView *progressBar;


- (void) loadProjectList;
- (void)updateSyncURL;
- (void) forgetSync; 

@end
