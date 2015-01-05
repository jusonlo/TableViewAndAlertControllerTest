//
//  ViewController.m
//  Sections
//
//  Created by steven on 15/1/3.
//  Copyright (c) 2015年 steven. All rights reserved.
//

#import "ViewController.h"

static NSString *SectionsTableIndentifier=@"SectionsTableIndentifier";
@interface ViewController ()
@property(copy,nonatomic)NSDictionary *names;
@property(copy,nonatomic)NSArray *keys;

@end

@implementation ViewController
{
    NSMutableArray *filteredNames;
    UISearchDisplayController *searchController;
    UIAlertAction *alertAction;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSString *path =[[NSBundle mainBundle] pathForResource:@"sortednames" ofType:@"plist"];
    self.names =[NSDictionary dictionaryWithContentsOfFile:path];
    self.keys =[[self.names allKeys] sortedArrayUsingSelector:@selector(compare:)];
    
    
    UITableView *tableView=(id)[self.view viewWithTag:1];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SectionsTableIndentifier];
    
    if (tableView.style== UITableViewStylePlain) {
        UIEdgeInsets contentInset=tableView.contentInset;
        contentInset.top=40;
        [tableView setContentInset:contentInset];
        tableView.tableFooterView =[[UITableView alloc]init];
        
        UIView *background =[[UIView alloc]initWithFrame:CGRectMake(0, 0, 750, 20)];
        background.backgroundColor=[UIColor colorWithWhite:1.0 alpha:1.0];
        [self.view addSubview:background];
    }
    
    filteredNames =[NSMutableArray array];
    UISearchBar *searchBar=[[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 750, 45)];
    tableView.tableHeaderView = searchBar;
    
    searchController =[[UISearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
    [searchController.searchBar sizeToFit];
    searchController.delegate = self;
    searchController.searchResultsDataSource =self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark tableview data source methods

// 列表的总数
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView.tag == 1) {
        return self.keys.count;
    }else{
        return 1;
    }
}

// 每一个选项的总数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 1) {
    NSString *key = self.keys[section];
    NSArray *sectionArray = self.names[key];
    return sectionArray.count;
    }else{
        return filteredNames.count;
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (tableView.tag == 1) {
    return self.keys[section];
    }else{
        return nil;
    }
}

// 显示每一列
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:SectionsTableIndentifier forIndexPath:indexPath];
    if (tableView.tag == 1) {
    NSString *key = self.keys[indexPath.section];
    NSArray *sectionArray = self.names[key];
    
    cell.textLabel.text = sectionArray[indexPath.row];
    }
    else{
        cell.textLabel.text=filteredNames[indexPath.row];
    }
    return  cell;
}

// 选择某一行时，实现弹出一个对话框
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *key=self.keys[indexPath.section];
    NSArray *nameArray = self.names[key];
    NSString *message = [[NSString alloc] initWithFormat:@"你选择了：%@",nameArray[indexPath.row]];
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"消息" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:@"登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alert.textFields.firstObject];
        
        UIAlertController *sureController =[UIAlertController alertControllerWithTitle:@"消息" message:@"确定登录吗？" preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *sureAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSLog(@"点击了确定按钮！");
            NSString *info=nil;
            if ([@"12345" isEqualToString: ((UITextField *)alert.textFields.firstObject).text]) {
                info=@"密码匹配成功！";
            }else{
                info=@"密码不匹配！";
            }
            
            UIAlertController *infoController = [UIAlertController alertControllerWithTitle:@"消息" message:info preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *infoAction =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}];
            [infoController addAction:infoAction];
            [self presentViewController:infoController animated:YES completion:^{
                
            }];
        }];
        UIAlertAction *noAction =[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            NSLog(@"点击了取消按钮！");
        }];
        [sureController addAction:sureAction];
        [sureController addAction:noAction];
        [self presentViewController:sureController animated:YES completion:^{}];
    }];
    loginAction.enabled = NO;
    alertAction = loginAction;
    
    UIAlertAction *cannelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:alert.textFields.firstObject];
    }];
    [alert addAction:loginAction];
    [alert addAction:cannelAction];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextFieldTextDidChangeNotification:) name:UITextFieldTextDidChangeNotification object:textField];
        textField.secureTextEntry = YES;
    }];
    
    [self presentViewController:alert animated:YES completion:^{
        NSLog(@"The \"Okay/Cancel\" alert's cancel action occured.");
    }];
}

// 文本框发生改变时，执行的方法
- (void)handleTextFieldTextDidChangeNotification:(NSNotification *)notification {
    UITextField *textField = notification.object;
    alertAction.enabled = textField.text.length >= 5;
}

// 添加右侧索引
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if (tableView.tag == 1) {
    return  self.keys;
    }else{
        return nil;
    }
}

-(void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView{
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:SectionsTableIndentifier];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [filteredNames removeAllObjects];
    if (searchString.length > 0) {
        NSPredicate *predicate=[NSPredicate predicateWithBlock:^BOOL(NSString *name, NSDictionary *b){
            NSRange range=[name rangeOfString:searchString options:NSCaseInsensitiveSearch];
            return range.location!=NSNotFound;
        }];
    
    for (NSString *key in self.keys) {
        NSArray *matches =[self.names[key] filteredArrayUsingPredicate:predicate];
        [filteredNames addObjectsFromArray:matches];
    }
    }
    return YES;
}


@end
