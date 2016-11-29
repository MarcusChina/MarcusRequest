
# MarcusRequest
基于AFNetworking，使用代理方式对网络请求再封装，可实现网络请求自动取消。

1、该网络请求封装是基于AFNetworking 3.0 以上版本的，所以在使用该请求封装时，项目需要引入AFNetworking网络库3.0 以上版本；

2、将该项目中MSRequstManager目录下的四个文件导入到需要使用的项目中，（MSAPIBaseManager.h MSAPIBaseManager.m 
   MSNetWorkingManager.h MSNetWorkingManager.m）

3、创建网络请求Manager，每个Manager都要继承MSAPIBaseManager类，例如Demo中的：MSTaoBaoSearchManager、MSDuoMiManager

4、在具体的网络Manager中可以配置网络请求类型，网络请求url(url中可拼接参数但是不推荐)

5、根据需要在特定的VC中发起网络请求，例如MSDemoViewController中发起MSTaoBaoSearchManager和MSDuoMiManager请求，
   实现对应的代理方法：
                     a).请求参数代理方法 -(NSDictionary *)paramsForApi:(MSAPIBaseManager *)manager
                     
                     b).请求成功回调代理方法：-(void)managerCallAPIDidSuccess:(MSAPIBaseManager *)manager
                     
                     c).请求失败回调代理方法: -(void)managerCallAPIDidFailed:(MSAPIBaseManager *)manager

6、若VC销毁，该VC下所有的未完成的请求会自动取消。





如使用中有问题，可邮件至 marcus2015@163.com
