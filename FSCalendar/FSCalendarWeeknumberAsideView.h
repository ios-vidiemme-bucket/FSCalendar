//
//  FSCalendarWeeknumberAsideView.h
//  Pods
//
//  Created by Federico Frappi on 11/01/19.
//
//

#import <UIKit/UIKit.h>

@class FSCalendar, FSCalendarAppearance, FSCalendarWeeknumberAsideLayout, FSCalendarCollectionView;

@interface FSCalendarWeeknumberAsideView : UIView

@property (weak, nonatomic) FSCalendarCollectionView *collectionView;
@property (weak, nonatomic) FSCalendarWeeknumberAsideLayout *collectionViewLayout;
@property (weak, nonatomic) FSCalendar *calendar;

@property (assign, nonatomic) UICollectionViewScrollDirection scrollDirection;
@property (assign, nonatomic) BOOL scrollEnabled;

- (void)setScrollOffset:(CGFloat)scrollOffset;
- (void)setScrollOffset:(CGFloat)scrollOffset animated:(BOOL)animated;
- (void)reloadData;
- (void)configureAppearance;

@end


@interface FSCalendarWeeknumberAsideWeekCell : UICollectionViewCell

@property (weak, nonatomic) UILabel *titleLabel;
@property (weak, nonatomic) FSCalendarWeeknumberAsideView *aside;

@end


@interface FSCalendarWeeknumberAsideMonthCell : UICollectionViewCell

@property (weak, nonatomic) UIStackView *titleLabels;
@property (weak, nonatomic) FSCalendarWeeknumberAsideView *aside;

@end


@interface FSCalendarWeeknumberAsideLayout : UICollectionViewFlowLayout

@end


@interface FSCalendarWeeknumberAsideTouchDeliver : UIView

@property (weak, nonatomic) FSCalendar *calendar;
@property (weak, nonatomic) FSCalendarWeeknumberAsideView *aside;

@end
