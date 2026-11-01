#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIKit.h>

#import "NNSettings.h"

@interface NightNightRootListController : PSListController
@end

@implementation NightNightRootListController

- (NSArray *)specifiers {
    NSArray *specifiers = [self valueForKey:@"_specifiers"];
    if (specifiers.count == 0) {
        specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
        if (specifiers) {
            [self setValue:specifiers forKey:@"_specifiers"];
        }
    }
    [self updateThresholdSpecifiers:specifiers];
    return specifiers;
}

- (void)updateThresholdSpecifiers:(NSArray *)specifiers {
    NSArray *list = specifiers ?: [self valueForKey:@"_specifiers"];
    BOOL autoEnabled = [NNSettings autoHibernate];
    BOOL wakeOnCharger = [NNSettings wakeOnCharger];
    for (PSSpecifier *specifier in list) {
        NSString *key = [specifier propertyForKey:PSKeyNameKey];
        if ([key isEqualToString:@"SleepLevel"]) {
            [specifier setProperty:@(autoEnabled) forKey:PSEnabledKey];
        } else if ([key isEqualToString:@"WakeLevel"]) {
            [specifier setProperty:@(autoEnabled && !wakeOnCharger) forKey:PSEnabledKey];
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"NightNight";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateThresholdSpecifiers:nil];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];

    NSString *identifier = [specifier propertyForKey:@"key"];
    if ([identifier isEqualToString:@"SleepLevel"] || [identifier isEqualToString:@"WakeLevel"]) {
        NSInteger sleepLevel = [NNSettings sleepLevel];
        NSInteger wakeLevel = [NNSettings wakeLevel];
        if (wakeLevel <= sleepLevel) {
            [NNSettings setInteger:sleepLevel + 1 forKey:@"WakeLevel"];
            [self reloadSpecifiers];
        }
    }
    if ([identifier isEqualToString:@"AutoHibernate"] ||
        [identifier isEqualToString:@"WakeOnCharger"]) {
        [self updateThresholdSpecifiers:nil];
        [self reloadSpecifiers];
    }

    [NNSettings postChanged];
}

- (void)hibernateNow:(PSSpecifier *)specifier {
    [NNSettings postManualHibernate];
}

- (void)resetDefaults:(PSSpecifier *)specifier {
    [NNSettings resetToDefaults];
    [self reloadSpecifiers];
}

@end
