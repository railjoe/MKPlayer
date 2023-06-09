/*! \file IMAAdEvent.h
 * GoogleIMA3
 *
 * Copyright (c) 2013 Google Inc. All rights reserved.
 *
 * Defines a data object used to convey information during ad playback.
 * This object is sent to the IMAAdsManager delegate.
 */

#import <Foundation/Foundation.h>

#import "IMAAd.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark IMAAdEventType

/**
 * Different event types sent by the IMAAdsManager to its delegate.
 */
typedef NS_ENUM(NSInteger, IMAAdEventType) {
  /**
   * Ad break ready.
   */
  kIMAAdEvent_AD_BREAK_READY,
  /**
   * Ad break will not play back any ads.
   */
  kIMAAdEvent_AD_BREAK_FETCH_ERROR,
  /**
   * Fired the first time each ad break ends. Applications must reenable seeking
   * when this occurs (only used for dynamic ad insertion).
   */
  kIMAAdEvent_AD_BREAK_ENDED,
  /**
   * Fired first time each ad break begins playback. If an ad break is watched
   * subsequent times this  will not be fired. Applications must disable seeking
   * when this occurs (only used for dynamic ad insertion).
   */
  kIMAAdEvent_AD_BREAK_STARTED,
  /**
   * Fired every time the stream switches from advertising or slate to content.
   * This will be fired even when an ad is played a second time or when seeking
   * into an ad (only used for dynamic ad insertion).
   */
  kIMAAdEvent_AD_PERIOD_ENDED,
  /**
   * Fired every time the stream switches from content to advertising or slate.
   * This will be fired even when an ad is played a second time or when seeking
   * into an ad (only used for dynamic ad insertion).
   */
  kIMAAdEvent_AD_PERIOD_STARTED,
  /**
   * All valid ads managed by the ads manager have completed or the ad response
   * did not return any valid ads.
   */
  kIMAAdEvent_ALL_ADS_COMPLETED,
  /**
   * Ad clicked.
   */
  kIMAAdEvent_CLICKED,
  /**
   * Single ad has finished.
   */
  kIMAAdEvent_COMPLETE,
  /**
   * Cuepoints changed for VOD stream (only used for dynamic ad insertion).
   * For this event, the <code>IMAAdEvent.adData</code> property contains a list of
   * <code>IMACuepoint</code>s at <code>IMAAdEvent.adData[@"cuepoints"]</code>.
   */
  kIMAAdEvent_CUEPOINTS_CHANGED,
  /**
   * The user has closed the icon fallback image dialog. This may be a good time to resume ad
   * playback, which the SDK autopaused on icon tap. This event only fires for tvOS.
   */
  kIMAAdEvent_ICON_FALLBACK_IMAGE_CLOSED,
  /**
   * The user has tapped an ad icon. On iOS, the SDK will navigate to the landing page. On tvOS, the
   * SDK will present a modal dialog containing the VAST icon fallback image.
   */
  kIMAAdEvent_ICON_TAPPED,
  /**
   * First quartile of a linear ad was reached.
   */
  kIMAAdEvent_FIRST_QUARTILE,
  /**
   * An ad was loaded.
   */
  kIMAAdEvent_LOADED,
  /**
   * A log event for the ads being played. These are typically non fatal errors.
   */
  kIMAAdEvent_LOG,
  /**
   * Midpoint of a linear ad was reached.
   */
  kIMAAdEvent_MIDPOINT,
  /**
   * Ad paused.
   */
  kIMAAdEvent_PAUSE,
  /**
   * Ad resumed.
   */
  kIMAAdEvent_RESUME,
  /**
   * Ad has skipped.
   */
  kIMAAdEvent_SKIPPED,
  /**
   * Ad has started.
   */
  kIMAAdEvent_STARTED,
  /**
   * Stream request has loaded (only used for dynamic ad insertion).
   */
  kIMAAdEvent_STREAM_LOADED,
  /**
   * Stream has started playing (only used for dynamic ad insertion). Start
   * Picture-in-Picture here if applicable.
   */
  kIMAAdEvent_STREAM_STARTED,
  /**
   * Ad tapped.
   */
  kIMAAdEvent_TAPPED,
  /**
   * Third quartile of a linear ad was reached.
   */
  kIMAAdEvent_THIRD_QUARTILE
};

#pragma mark - Ad Data Keys

/**
 * The key for the time in seconds when the AD_BREAK_READY event fired.
 */
extern NSString *const kIMAAdBreakTime;

#pragma mark - IMAAdEvent

/**
 * Simple data class used to transport ad playback information.
 */
@interface IMAAdEvent : NSObject

/**
 * Type of the event.
 */
@property(nonatomic, readonly) IMAAdEventType type;

/**
 * Stringified type of the event.
 */
@property(nonatomic, copy, readonly) NSString *typeString;

/**
 * The current ad that is playing or just played. This will be nil except for
 * events where an ad is available (start, quartiles, midpoint, complete, and tap).
 */
@property(nonatomic, readonly, nullable) IMAAd *ad;

/**
 * Extra data about the ad.
 */
@property(nonatomic, copy, readonly, nullable) NSDictionary<NSString *, id> *adData;

/**
 * :nodoc:
 */
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
