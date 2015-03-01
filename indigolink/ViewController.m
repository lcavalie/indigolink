//
//  ViewController.m
//  indigolink
//
//  Created by Konstantinos Vlassis on 2015/3/1.
//  Copyright (c) 2015 Konstantinos Vlassis. All rights reserved.
//

#import "ViewController.h"
#import "indigolink-Bridging-Header.h"
#import "SRWebSocket.h"
#import "indigolink-Swift.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UILabel *labelUsername;
@property (weak, nonatomic) IBOutlet UILabel *labelPassword;
@property (weak, nonatomic) IBOutlet UILabel *labelServerIP;
@property (weak, nonatomic) IBOutlet UILabel *labelServerPort;

@property (weak, nonatomic) IBOutlet UITextField *textUsername;
@property (weak, nonatomic) IBOutlet UITextField *textPassword;
@property (weak, nonatomic) IBOutlet UITextField *textServerIP;
@property (weak, nonatomic) IBOutlet UITextField *textServerPort;


@end

@implementation ViewController

SRWebSocket *webSocket;

NSString *accessToken;

NSString *server_ip;
NSString *server_port;

NSManagedObject *existingItem;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self readServerSettings];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)indigoConnect:(id)sender {
    
    [self saveServerSettings];
    
    [self connectWebSocket];
    
}

- (void) connectionLost {
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"indigo link"
                                                    message:@"Connection to the server lost!"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Retry", nil];
    
    [alert show];
    
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        
        [self connectWebSocket];
        
    } else {
        
        //go back to this ViewController...
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    
}

//begin SocketRocket implementation

#pragma mark - Connection

- (void)connectWebSocket {
    webSocket.delegate = nil;
    webSocket = nil;
    
    NSString *urlString = [NSString stringWithFormat: @"wss://%@:%@", server_ip, server_port];
    
    //NSLog(@"%@", urlString);
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                             cachePolicy: NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:5.0];
    
    SRWebSocket *newWebSocket = [[SRWebSocket alloc] initWithURLRequest: request];
    newWebSocket.delegate = self;
    
    [newWebSocket open];
    
}

- (void) closeConnection {
    [webSocket close];
}

#pragma mark - SRWebSocket delegate

- (void)webSocketDidOpen:(SRWebSocket *)newWebSocket {
    webSocket = newWebSocket;
    [webSocket send:[NSString stringWithFormat:@"%@: iam: %@", accessToken, [UIDevice currentDevice].name]];
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    //[self connectWebSocket];
    [self connectionLost];
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    //[self connectWebSocket];
    [self connectionLost];
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    syncDevices *syncDev = [syncDevices new];
    
    NSArray *devArr;
    
    devArr = [syncDev parseDeviceXMLData:data];
    
    if ([self.navigationController.visibleViewController isKindOfClass:[DeviceListTableViewController class]]) {
        
        if (devArr.count>1) {
            [(DeviceListTableViewController *)self.navigationController.visibleViewController deviceUpdateAll];
        } else if (devArr.count == 1){
            [(DeviceListTableViewController *)self.navigationController.visibleViewController deviceUpdate:devArr[0]];
        } else {
            NSLog(@"No device or invalid XML!");
        }
        
    } else if ([self.navigationController.visibleViewController isKindOfClass:[DeviceGroupViewController class]]) {
        
        [(DeviceGroupViewController *)self.navigationController.visibleViewController stopInd];
        
    } else if ([self.navigationController.visibleViewController isKindOfClass:[SettingsController class]]) {
        
        [(SettingsController *)self.navigationController.visibleViewController alarmUpdate];
        
    } else {
        //        NSLog(@"Controller FAIL!");
    }
    
    //NSLog(@"Received: %@", message);
}


- (void)sendMessage:(NSString*) sendCommand message:(NSString*) sendContent {
    
    NSString *response  = [NSString stringWithFormat: @"%@:%@%@", accessToken, sendCommand, sendContent];
    
    [webSocket send:response];
    
    NSLog(@"clint sent: %@", response);
    
    
}


- (NSManagedObjectContext *)managedObjectContext {
    
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
    
}


- (void) readServerSettings {
    
    NSMutableArray *devices;
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"IndigoServerSettings"];
    devices = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    
    if (devices.count > 0) {
        
        NSManagedObject *device;
        
        for (device in devices) {
            
            //NSLog(@"from Core Data: %@:%@", [device valueForKey:@"server_ip"], [device valueForKey:@"server_port"]);
            
            server_ip = [device valueForKey:@"server_ip"];
            server_port = [device valueForKey:@"server_port"];
            
            self.textUsername.text = [device valueForKey:@"server_username"];
            self.textPassword.text = [device valueForKey:@"server_password"];
            self.textServerIP.text = server_ip;
            self.textServerPort.text = server_port;
            
            existingItem = device;
        }
        
    }
    
}

- (void) saveServerSettings {
    
    
    NSManagedObjectContext *context = [self managedObjectContext];
    NSString *str_api_username = self.textUsername.text;
    NSString *str_api_password = self.textPassword.text;
    NSString *str_api_server_ip = self.textServerIP.text;
    NSString *str_api_server_port = self.textServerPort.text;
    
    server_ip = str_api_server_ip;
    server_port = str_api_server_port;
    
    NSString *plainString = [NSString stringWithFormat: @"%@:%@", str_api_username, str_api_password];
    NSData *plainData = [plainString dataUsingEncoding:NSUTF8StringEncoding];
    accessToken = [plainData base64EncodedStringWithOptions:0];
    
    if (existingItem !=nil) {
        [existingItem setValue:str_api_username forKey:@"server_username"];
        [existingItem setValue:str_api_password forKey:@"server_password"];
        [existingItem setValue:str_api_server_ip forKey:@"server_ip"];
        [existingItem setValue:str_api_server_port forKey:@"server_port"];
        
    } else {
        
        NSManagedObject *newDevice = [NSEntityDescription insertNewObjectForEntityForName:@"IndigoServerSettings" inManagedObjectContext:context];
        
        [newDevice setValue:str_api_username forKey:@"server_username"];
        [newDevice setValue:str_api_password forKey:@"server_password"];
        [newDevice setValue:str_api_server_ip forKey:@"server_ip"];
        [newDevice setValue:str_api_server_port forKey:@"server_port"];
        
    }
    
    [context save:nil];
    
}


@end
