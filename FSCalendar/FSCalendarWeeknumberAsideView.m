//
//  FSCalendarWeeknumberAsideView.h
//  Pods
//
//  Created by Federico Frappi on 11/01/19.
//
//

#import "FSCalendar.h"
#import "FSCalendarExtensions.h"
#import "FSCalendarWeeknumberAsideView.h"
#import "FSCalendarCollectionView.h"
#import "FSCalendarDynamicHeader.h"

@interface FSCalendarWeeknumberAsideView ()<UICollectionViewDataSource,UICollectionViewDelegate,FSCalendarCollectionViewInternalDelegate>

- (void)scrollToOffset:(CGFloat)scrollOffset animated:(BOOL)animated;
- (void)configureWeekCell:(FSCalendarWeeknumberAsideWeekCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)configureMonthCell:(FSCalendarWeeknumberAsideMonthCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation FSCalendarWeeknumberAsideView

#pragma mark - Life cycle

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize{
    _scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _scrollEnabled = YES;
    
    FSCalendarWeeknumberAsideLayout *collectionViewLayout = [[FSCalendarWeeknumberAsideLayout alloc] init];
    self.collectionViewLayout = collectionViewLayout;
    
    FSCalendarCollectionView *collectionView = [[FSCalendarCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:collectionViewLayout];
    collectionView.scrollEnabled = NO;
    collectionView.userInteractionEnabled = NO;
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    [self addSubview:collectionView];
    [collectionView registerClass:[FSCalendarWeeknumberAsideWeekCell class] forCellWithReuseIdentifier:@"weekCell"];
    [collectionView registerClass:[FSCalendarWeeknumberAsideMonthCell class] forCellWithReuseIdentifier:@"monthCell"];
    self.collectionView = collectionView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.collectionView.frame = CGRectMake(self.fs_width*0.1, 0, self.fs_width*0.9, self.fs_height);
}

- (void)dealloc{
    self.collectionView.dataSource = nil;
    self.collectionView.delegate = nil;
}

#pragma mark - <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    switch (self.calendar.transitionCoordinator.representingScope) {
        case FSCalendarScopeMonth:
            return self.calendar.calculator.numberOfMonths;
            break;
        case FSCalendarScopeWeek:
            return self.calendar.calculator.numberOfWeeks;
            break;
        default:
            break;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    switch (self.calendar.transitionCoordinator.representingScope) {
        case FSCalendarScopeMonth: {
            FSCalendarWeeknumberAsideMonthCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"monthCell" forIndexPath:indexPath];
            cell.aside = self;
            [self configureMonthCell:cell atIndexPath:indexPath];
            return cell;
        }
        case FSCalendarScopeWeek: {
            FSCalendarWeeknumberAsideWeekCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"weekCell" forIndexPath:indexPath];
            cell.aside = self;
            [self configureWeekCell:cell atIndexPath:indexPath];
            return cell;
        }
        default:
            return [[UICollectionViewCell alloc] init];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
}

#pragma mark - Properties

- (void)setCalendar:(FSCalendar *)calendar{
    _calendar = calendar;
    [self configureAppearance];
}

- (void)setScrollOffset:(CGFloat)scrollOffset{
    [self setScrollOffset:scrollOffset animated:NO];
}

- (void)setScrollOffset:(CGFloat)scrollOffset animated:(BOOL)animated{
    [self scrollToOffset:scrollOffset animated:NO];
}

- (void)scrollToOffset:(CGFloat)scrollOffset animated:(BOOL)animated{
    if (self.calendar.transitionCoordinator.representingScope == FSCalendarScopeWeek) {
        scrollOffset += 1;
    }
    
    if (self.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        CGFloat step = self.collectionView.fs_width;
        [_collectionView setContentOffset:CGPointMake(scrollOffset * step, 0) animated:animated];
    } else {
        CGFloat step = self.collectionView.fs_height;
        [_collectionView setContentOffset:CGPointMake(0, scrollOffset * step) animated:animated];
    }
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection{
    if (_scrollDirection != scrollDirection) {
        _scrollDirection = scrollDirection;
        _collectionViewLayout.scrollDirection = scrollDirection;
        [self setNeedsLayout];
    }
}

- (void)setScrollEnabled:(BOOL)scrollEnabled{
    if (_scrollEnabled != scrollEnabled) {
        _scrollEnabled = scrollEnabled;
        [_collectionView.visibleCells makeObjectsPerformSelector:@selector(setNeedsLayout)];
    }
}

#pragma mark - Public

- (void)reloadData{
    [_collectionView reloadData];
}

- (void)configureWeekCell:(FSCalendarWeeknumberAsideWeekCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    FSCalendarAppearance *appearance = self.calendar.appearance;
    cell.titleLabel.font = appearance.weekdayFont;
    cell.titleLabel.textColor = appearance.weekdayTextColor;
    
    NSDate *firstPage = [self.calendar.calendarWrapper fs_middleDayOfWeek:self.calendar.minimumDate];
    NSDate *date = [self.calendar.calendarWrapper dateByAddingUnit:NSCalendarUnitWeekOfYear value:indexPath.item-1 toDate:firstPage options:0];
    NSString *text = [NSString stringWithFormat:@"%@", [_calendar.calendarWrapper fs_weekNumberForDate:date]];
    cell.titleLabel.text = text;

    [cell setNeedsLayout];
}

- (void)configureMonthCell:(FSCalendarWeeknumberAsideMonthCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    FSCalendarAppearance *appearance = self.calendar.appearance;
    
    NSArray *subviews = cell.titleLabels.subviews;
    for(UIView *subview in subviews) {
        [subview removeFromSuperview];
    }
    
    NSDate *firstOfMonth = [self.calendar.calendarWrapper fs_firstDayOfMonthByAddingMonths:indexPath.item toDate:self.calendar.minimumDate];
    NSDate *lastOfMonth = [self.calendar.calendarWrapper fs_lastDayOfMonth:firstOfMonth];
    
    NSInteger firstDayOfMonthWeekNumber = [[self.calendar.calendarWrapper fs_weekNumberForDate:firstOfMonth] integerValue];
    NSInteger lastDayOfMonthWeekNumber = [[self.calendar.calendarWrapper fs_weekNumberForDate:lastOfMonth] integerValue];

    NSInteger numberOfWeeks = self.calendar.placeholderType == FSCalendarPlaceholderTypeFillSixRows ? 6 : (lastDayOfMonthWeekNumber - firstDayOfMonthWeekNumber + 1 );
    
    for (NSInteger i=0; i<6; i++) {
        NSDate* firstOfWeek = [self.calendar.calendarWrapper dateByAddingUnit:NSCalendarUnitWeekOfYear value:i toDate:firstOfMonth options:0];
        NSString *weekNumber = [self.calendar.calendarWrapper fs_weekNumberForDate:firstOfWeek];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.font = appearance.weekdayFont;
        label.textColor = appearance.weekdayTextColor;
        [cell.titleLabels addArrangedSubview:label];
        
        label.text = i < numberOfWeeks ? weekNumber : nil;
    }
    
    [cell setNeedsLayout];
}

- (void)configureAppearance{
    [self.collectionView.visibleCells enumerateObjectsUsingBlock:^(UICollectionViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([cell isKindOfClass:[FSCalendarWeeknumberAsideWeekCell class]]) {
            [self configureWeekCell:(FSCalendarWeeknumberAsideWeekCell *)cell atIndexPath:[self.collectionView indexPathForCell:cell]];
        } else if ([cell isKindOfClass:[FSCalendarWeeknumberAsideMonthCell class]]) {
            [self configureMonthCell:(FSCalendarWeeknumberAsideMonthCell *)cell atIndexPath:[self.collectionView indexPathForCell:cell]];
        }
    }];
}

@end


@implementation FSCalendarWeeknumberAsideWeekCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
    }
    return self;
}

- (void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    self.titleLabel.frame = bounds;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.titleLabel.frame = self.contentView.bounds;
}

@end

@implementation FSCalendarWeeknumberAsideMonthCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        UIStackView *titleLabels = [[UIStackView alloc] initWithFrame:CGRectZero];
        titleLabels.alignment = UIStackViewAlignmentFill;
        titleLabels.distribution = UIStackViewDistributionFillEqually;
        titleLabels.axis = UILayoutConstraintAxisVertical;
        [self.contentView addSubview:titleLabels];
        self.titleLabels = titleLabels;
    }
    return self;
}

- (void)setBounds:(CGRect)bounds{
    [super setBounds:bounds];
    self.titleLabels.frame = bounds;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.titleLabels.frame = self.contentView.bounds;
}

@end


@implementation FSCalendarWeeknumberAsideLayout

- (instancetype)init{
    self = [super init];
    if (self) {
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.minimumInteritemSpacing = 0;
        self.minimumLineSpacing = 0;
        self.sectionInset = UIEdgeInsetsZero;
        self.itemSize = CGSizeMake(1, 1);
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(didReceiveOrientationChangeNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)prepareLayout{
    [super prepareLayout];
    
    self.itemSize = CGSizeMake(
                               self.collectionView.fs_width,
                               self.collectionView.fs_height
                              );
    
}

- (void)didReceiveOrientationChangeNotification:(NSNotification *)notificatino{
    [self invalidateLayout];
}

- (BOOL)flipsHorizontallyInOppositeLayoutDirection{
    return YES;
}

@end

@implementation FSCalendarWeeknumberAsideTouchDeliver

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    UIView *hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        return _calendar.collectionView ?: hitView;
    }
    return hitView;
}

@end


