//
//  ViewController.m
//  Demo_3
//
//  Created by MacBookPro on 2022/1/12.
//

#import "ViewController.h"
#import <ARKit/ARKit.h>
@interface ViewController ()<ARSCNViewDelegate>
@property (nonatomic,strong) ARSCNView * scnview;
@property (nonatomic,strong) ARConfiguration * arConfig;
@property (nonatomic,strong) UIView * maskView;
@property (nonatomic,strong) UILabel * tipLabel;
@property (nonatomic,strong) UILabel *infoLabel;
@end

@implementation ViewController

- (ARSCNView *)scnview {
    if (nil == _scnview) {
        _scnview = [[ARSCNView alloc] initWithFrame:self.view.bounds];
    }
    return  _scnview;
}

- (ARConfiguration *)arConfig {
    if (nil == _arConfig) {
        if ([ARWorldTrackingConfiguration isSupported]) {
            ARWorldTrackingConfiguration * config = [ARWorldTrackingConfiguration new];
            config.planeDetection = true;
            config.lightEstimationEnabled = true;
            _arConfig = config;
        } else {
            AROrientationTrackingConfiguration * config = [AROrientationTrackingConfiguration new];
            _arConfig = config;
            self.tipLabel.text = @"当前设备不支持6DOE跟踪";
        }
    }
    return  _arConfig;
}

- (UIView *)maskView {
    if (nil == _maskView) {
        _maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        _maskView.backgroundColor = UIColor.whiteColor;
        _maskView.alpha = 0.6f;
    }
    return  _maskView;
}

- (UILabel *)infoLabel {
    if (nil == _infoLabel) {
        _infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.tipLabel.frame), CGRectGetWidth(self.tipLabel.frame), 150)];
        _infoLabel.numberOfLines = 0;
        _infoLabel.textColor = UIColor.blackColor;
    }
    return  _infoLabel;
}

- (UILabel *)tipLabel {
    if (nil == _tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, CGRectGetWidth(self.scnview.frame), 50)];
        _tipLabel.numberOfLines = 0;
        _tipLabel.textColor = UIColor.blackColor;
    }
    return  _tipLabel;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.scnview];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.infoLabel];
    [self.view addSubview:self.tipLabel];
    self.scnview.delegate = self;
    self.scnview.showsStatistics = true;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super  viewWillAppear:animated];
    [self.scnview.session  runWithConfiguration:self.arConfig];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.scnview.session  pause];
}


#pragma- ARSCNViewDelegate
- (void)session:(ARSession *)session cameraDidChangeTrackingState:(ARCamera *)camera {
    switch (camera.trackingState) {
        case ARTrackingStateNotAvailable: {
            self.tipLabel.text = @"跟踪不可用";
            [UIView animateWithDuration:0.6 animations:^{
                self.maskView.alpha = 0.7;
            }];

            break;
        }
        case ARTrackingStateLimited: {
            NSString * title = @"有限的跟踪，原因为：";
            NSString * decs ;
            switch (camera.trackingStateReason) {
                case ARTrackingStateReasonNone:
                    decs = @"不受约束";
                    break;
                case ARTrackingStateReasonInitializing:
                    decs = @"正在初始化";
                case  ARTrackingStateReasonExcessiveMotion:
                    decs = @"设备移动过快，请注意";
                case ARTrackingStateReasonInsufficientFeatures:
                    decs = @"提取不到足够的特征点，请移动设备";
                default:
                    break;
            }
            self.tipLabel.text = [NSString stringWithFormat:@"%@%@",title,decs];
            [UIView animateWithDuration:0.5 animations:^{
                self.maskView.alpha = 0.6;
            }];
        }
        case ARTrackingStateNormal: {
            self.tipLabel.text = @"跟踪正常";
            [UIView animateWithDuration:0.5 animations:^{
                self.maskView.alpha = 0.0;
            }];
            break;
        }
        default:
            break;
    }
    
}

- (void)sessionWasInterrupted:(ARSession *)session {
    self.tipLabel.text = @"会话终端";
}

-(void)sessionInterruptionEnded:(ARSession *)session {
    self.tipLabel.text = @"会话中断结束,已重置会话";
    [self.scnview.session runWithConfiguration:self.arConfig options:ARSessionRunOptionResetTracking];
}

-(void)session:(ARSession *)session didFailWithError:(NSError *)error {
    switch (error.code) {
        case ARErrorCodeUnsupportedConfiguration:
            self.tipLabel.text = @"当前设备不支持";
            break;
        case ARErrorCodeSensorUnavailable:
            self.tipLabel.text = @"传感器不可用,请检查传感器";
        case ARErrorCodeSensorFailed:
            self.tipLabel.text = @"传感器出错,请检查设备";
        case ARErrorCodeCameraUnauthorized:
            self.tipLabel.text = @"摄像头没授权";
        case ARErrorCodeWorldTrackingFailed:
            self.tipLabel.text = @"跟踪出错,请处置";
        default:
            break;
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    matrix_float4x4 transform = self.scnview.session.currentFrame.camera.transform;
    NSMutableString * infoStr = [NSMutableString new];
    for (int i = 0; i < 4;  i++) {
        [infoStr appendString:[NSString stringWithFormat:@"%f,%f,%f,%f",transform.columns[i].x,transform.columns[i].y,transform.columns[i].z,transform.columns[i].w]];
    }
    self.tipLabel.text = infoStr;
}

@end
