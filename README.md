# CoreDateTools
针对CoreData的简单管理类，实现NSManagedObject与Model的分离，提供共用的查询，删除，更新数据的方法。
## 使用方法
1. 新建实体Entity
2. 创建继承CoreDataModel的 EntityModel类，并添加自定义属性
3. 创建自定义继承NSManagedObject的 Entity类，并添加自定义属性
4. 创建继承于CoreDataModelManager的EntityModelManager子类，子类必须实现
   CoreDataModelManagerProtocol的四个方法。
   
   


