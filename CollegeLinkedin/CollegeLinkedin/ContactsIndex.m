
//
//  ContactsIndex.m
//  CollegeLinkedin
//
//  Created by 赵磊 on 16/2/10.
//  Copyright © 2016年 赵磊. All rights reserved.
//

#import "ContactsIndex.h"

static NSString* const cellId = @"CellWithImgAndLabel";

@interface ContactsIndex ()

{
    UILocalizedIndexedCollation *theCollation;
    NSMutableArray *searchResults;
}

//从数据库读取的 contacts 原始数据
@property (nonatomic,strong ) NSMutableArray *contactArrayTemp;

//分组排序后的 contacts 数据
@property (nonatomic,strong ) NSMutableArray *dataSource;

@property (nonatomic, strong) NSMutableArray *indexTitles;

// 包含空数据的contactsArray
@property (nonatomic, strong) NSMutableArray *allArray;

@end

@implementation ContactsIndex

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [Config getTableViewFooter];
    
    self.searchDisplayController.searchResultsTableView.tableFooterView = [Config getTableViewFooter];
    
    [self setUpInitialData];
    
    [self LoadContactsData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setUpInitialData
{
    self.contactArrayTemp = [NSMutableArray array];
    self.dataSource       = [NSMutableArray array];
    self.indexTitles      = [NSMutableArray array];
    self.allArray         = [NSMutableArray array];
}

-(void)LoadContactsData
{
//    此处从json文件获取，最终应从数据库获取
    self.contactArrayTemp = [Contact mj_objectArrayWithKeyValuesArray:[Config getJsonArray:@"contacts"]];
    
/*
 * 对contacts排序并分类
 */
    
    theCollation = [UILocalizedIndexedCollation currentCollation];
    
    NSInteger sectionTitlesCount = [[theCollation sectionTitles] count];
    
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        [self.allArray addObject:[NSMutableArray array]];
    }
    
//    1⃣️ 判断每个模型对象分别对应哪个区域
    
    for (Contact *contact in self.contactArrayTemp) {
        NSInteger sectionNumber = [theCollation sectionForObject:contact collationStringSelector:@selector(name)];
        [[self.allArray objectAtIndex:sectionNumber] addObject:contact];
    }
    
//    2⃣️ 基于模型对象的本地化标题来排列模型对象
    
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        NSArray *contactsForSection = [self.allArray objectAtIndex:idx];
        [self.allArray replaceObjectAtIndex:idx withObject:[theCollation sortedArrayFromArray:contactsForSection collationStringSelector:@selector(name)]];
    }
    
    for (NSMutableArray *sectionArray in self.allArray) {
        if (sectionArray.count) {
            [self.dataSource addObject:sectionArray];
        }
    }
}

#pragma mark -- UITableViewDelegate

/*
 *  返回一个区域索引标题的数组，用于在列表右边显示，例如字母序列 A...Z 和 #。
 *  区域索引标题很短，通常不能多于两个 Unicode 字符。
 */

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return nil;
    }
    else
    {
        for (int i = 0; i < self.allArray.count; i++) {
            if ([[self.allArray objectAtIndex:i] count]) {
                [self.indexTitles addObject:[[theCollation sectionTitles] objectAtIndex:i]];
            }
        }
        return self.indexTitles;
    }
}

/*
 * 按层级的方式组织数据，即 tableView 的分组
 */

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return nil;
    }
    else
    {
        if (section == 0) {
            return nil;
        } else {
            NSMutableArray *titlesArray = [NSMutableArray array];
            for (int i = 0; i < self.allArray.count; i++) {
                if ([[self.allArray objectAtIndex:i] count]) {
                    [titlesArray addObject:[[theCollation sectionTitles] objectAtIndex:i]];
                }
            }
            return [titlesArray objectAtIndex:section-1];
        }
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return 1;
    }
    else{
        return self.dataSource.count+1;
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        return searchResults.count;
    }
    else{
        if (section == 0) {
            return 2;
        } else {
            return [[self.dataSource objectAtIndex:section-1] count];
        }
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CellWithImgAndLabel *cell = (CellWithImgAndLabel*)[self.tableView dequeueReusableCellWithIdentifier:cellId];
//    注意!!-- 此处必须用self.tableView而不能用tableView
//    否则当 tableview 为 searchResultsTableView 时获取不到重用cell
    
    if (tableView == self.searchDisplayController.searchResultsTableView)
    {
        Contact *contact = searchResults[indexPath.row];
        cell.label.text = contact.name;
    }
    else
    {
        if (indexPath.section == 0) {
            if (indexPath.row == 0) {
                [cell.image setImage:[UIImage imageNamed:@"新的好友"]];
                cell.label.text = @"新的好友";
            } else {
                [cell.image setImage:[UIImage imageNamed:@"校友大咖"]];
                cell.label.text = @"校友大咖";
            }
        } else {
            Contact *contact = (Contact *)[[self.dataSource objectAtIndex:indexPath.section-1] objectAtIndex:indexPath.row];
            cell.label.text = contact.name;
            [cell.image setImage:[UIImage imageNamed:@"手机联系人"]];
        }

    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 8;
    } else {
        return 22;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 60;
    } else {
        return 55;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row     = indexPath.row;

    if (section == 0) {
        if (row == 0) {
            [self performSegueWithIdentifier:@"toNewFriendVC" sender:nil];
        } else {
            [self performSegueWithIdentifier:@"toCelebrityVC" sender:nil];
        }
    } else {
        
    }
}


// 联系人搜索，可实现汉字搜索，汉语拼音搜索和拼音首字母搜索，
// 输入联系人名称，进行搜索， 返回搜索结果searchResults

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    searchResults = [[NSMutableArray alloc]init];
    if (_contactsSearchBar.text.length>0 && ![ChineseInclude isIncludeChineseInString:_contactsSearchBar.text]) {
        for (NSArray *section in self.dataSource) {
            for (Contact *contact in section)
            {
                
                if ([ChineseInclude isIncludeChineseInString:contact.name]) {
                    NSString *tempPinYinStr = [PinYinForObjc chineseConvertToPinYin:contact.name];
                    NSRange titleResult=[tempPinYinStr rangeOfString:_contactsSearchBar.text options:NSCaseInsensitiveSearch];
                    
                    if (titleResult.length>0) {
                        [searchResults addObject:contact];
                    }
                    else {
                        NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:contact.name];
                        NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:_contactsSearchBar.text options:NSCaseInsensitiveSearch];
                        if (titleHeadResult.length>0) {
                            [searchResults  addObject:contact];
                        }
                    }
                    NSString *tempPinYinHeadStr = [PinYinForObjc chineseConvertToPinYinHead:contact.name];
                    NSRange titleHeadResult=[tempPinYinHeadStr rangeOfString:_contactsSearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleHeadResult.length>0) {
                        [searchResults  addObject:contact];
                    }
                }
                else {
                    NSRange titleResult=[contact.name rangeOfString:_contactsSearchBar.text options:NSCaseInsensitiveSearch];
                    if (titleResult.length>0) {
                        [searchResults  addObject:contact];
                    }
                }
            }
        }
    } else if (_contactsSearchBar.text.length>0&&[ChineseInclude isIncludeChineseInString:_contactsSearchBar.text]) {
        
        for (NSArray *section in self.dataSource) {
            for (Contact *contact in section)
            {
                NSString *tempStr = contact.name;
                NSRange titleResult=[tempStr rangeOfString:_contactsSearchBar.text options:NSCaseInsensitiveSearch];
                if (titleResult.length>0) {
                    [searchResults addObject:contact];
                }
                
            }
        }
    }
    
}

@end
