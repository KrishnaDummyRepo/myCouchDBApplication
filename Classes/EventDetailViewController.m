
/*
     File: EventDetailViewController.m
 Abstract: The table view controller responsible for displaying the time, coordinates, and photo of an event, and allowing the user to select a photo for the event, or delete the existing photo.
 
  Version: 1.1
 */

#import "EventDetailViewController.h"
#import "Event.h"
#import <CouchCocoa/CouchCocoa.h>
#import <CouchCocoa/RESTBody.h>
#import <Couchbase/CouchbaseMobile.h>
#import "LocationsAppDelegate.h"
@implementation EventDetailViewController
@synthesize userTextField;
@synthesize passwrdText;
@synthesize textField;
@synthesize database;
@synthesize progressBar;
@synthesize projectArray;
@synthesize projectListTableView;
@synthesize event;
#pragma mark -
#pragma mark Lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.progressBar setProgress:0.0];
    self.projectListTableView.backgroundView = nil;
    self.projectListTableView.backgroundColor = [UIColor clearColor];
//    self.progressBar.hidden = YES;

}
- (void) loadProjectList {
    
    LocationsAppDelegate *appDelegate =(LocationsAppDelegate *) [[UIApplication sharedApplication]delegate];
    NSMutableArray *tempProjectArray = [NSMutableArray array];
    self.database = appDelegate.database;
    
    
    CouchDesignDocument* design = [appDelegate.database designDocumentWithName: @"projectCheck"];
    
    [design defineViewNamed: @"byProjectName"
                        map:[NSString stringWithFormat:@"function(doc) {if (doc.type == \"Document.Project\") {emit(doc._id,{name:doc.name, location:doc.location});}}"]];
    CouchQuery* query = [design queryViewNamed: @"byProjectName"];
    event = nil;
    NSLog(@"[Q] row %@",[query rows]);
    for (CouchQueryRow* row in [query rows]) {
        
        event = [Event modelForDocument:row.document];
        [tempProjectArray addObject: event];
    }
    
    
    
    self.projectArray = tempProjectArray;
    [self.projectListTableView reloadData];
}
- (void)updateSyncURL {
    
    if (!self.database)
        return;
    NSURL* newRemoteURL = nil; 
        
    NSArray *seperateString = [self.textField.text componentsSeparatedByString:@"://"];

    NSString *subUrl = [seperateString objectAtIndex:1];
    NSString *syncPoint = [NSString stringWithFormat: @"http://%@:%@@%@",self.userTextField.text,self.passwrdText.text,subUrl];
    
    if (syncPoint.length > 0)
        newRemoteURL = [NSURL URLWithString:syncPoint];
    [self forgetSync];
    
    NSArray *repls =  [self.database replicateWithURL: newRemoteURL exclusively:NO];
    _pull = [[repls objectAtIndex: 0] retain];
    _push = [[repls objectAtIndex: 1] retain];
    
    if(_pull.state == 3 && _push.state == 3) {
        
        [progressBar setProgress:0.0]; 
        progressBar.hidden = YES;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"wrong url" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    [_push addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
    [_pull addObserver: self forKeyPath: @"completed" options: 0 context: NULL];
        
}

/**< to remove observers which are instantiated during replication */
- (void) forgetSync {
    [_push removeObserver: self forKeyPath: @"completed"];
    [_push release];
    _push = nil;
    
    [_pull removeObserver: self forKeyPath: @"completed"];
    [_pull release];
    _pull = nil;
    
}
#pragma mark - Replication progress bar
#pragma mark
- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object 
                         change:(NSDictionary *)change context:(void *)context
{
    if (object == _pull || object == _push) {
        unsigned completed = _pull.completed+_push.completed;
        unsigned total = _pull.total+_pull.completed;
        
        if((completed > total) || (completed == 0 && total == 0))
        {                    
            [self loadProjectList];
        }
        else{
            NSLog(@"SYNC progress: %u / %u", completed, total);
            [self.progressBar setProgress:(completed / (float)total)];
            if (total > 0 && completed <= total) {
                
                if(completed == total) {
                    
                    //self.progressBar.hidden = YES;
                    [self loadProjectList];                
                
                } else {
                    [self.progressBar setProgress:(completed / (float)total)];
                    database.server.activityPollInterval = 1;
                    [self loadProjectList];
                }   
            } else {
                [self.progressBar setProgress:(completed / (float)total)];
                database.server.activityPollInterval = 1;
            }
        }
    } 
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
 return [self.projectArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Cell = @"CellIdentifier";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:Cell];
    
    if (cell == nil) { 
    cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1  reuseIdentifier:Cell]autorelease];
    cell.textLabel.text = [event name];
    cell.detailTextLabel.text = [event location];
}
    event = [self.projectArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [event name];
    cell.detailTextLabel.text = [event location];
    return cell;

}


#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
	[event release];
	[projectArray release];
    [projectListTableView release];
    [textField release];
    [passwrdText release];
    [database release];
    [userTextField release];
    [progressBar release];
    [super dealloc];
}

- (IBAction)syncBtnAction:(id)sender {
    [self.userTextField resignFirstResponder];
    [self.passwrdText resignFirstResponder];
    [self.textField resignFirstResponder];
    [self updateSyncURL];
}
@end
