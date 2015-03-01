//
//  ViewController.h
//  indigolink
//
//  Created by Konstantinos Vlassis on 2015/3/1.
//  Copyright (c) 2015 Konstantinos Vlassis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "indigolink-Bridging-Header.h"

NSInputStream *inputStream;
NSOutputStream *outputStream;
NSMutableArray * messages;


@interface ViewController : UIViewController <NSStreamDelegate>

@property (weak, nonatomic) IBOutlet UIButton *indigoConnect;

@property (strong, nonatomic) IBOutlet UIView *indigoView;

- (void)sendMessage:(NSString*) sendCommand message:(NSString*) sendMessage;

@end

