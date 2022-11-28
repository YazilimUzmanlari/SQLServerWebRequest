CREATE FUNCTION [dbo].[fnGetNestedCategories]
(
	@jsonData nvarchar(max)
)
Returns @Returned Table(Id int, ParentId int, Name nvarchar(max))
AS
BEGIN
	WITH NestedCategories(Id, ParentId, Name, SubCategories) as
	(
		Select	Cast(json_value(Category.[value], '$.id') as int) Id, 
				Cast(json_value(Category.[value], '$.parentId') as int) ParentId, 
				Cast(json_value(Category.[value], '$.name') as nvarchar(max)) Name, 
				Cast(json_query(Category.[value], '$.subCategories') as nvarchar(max)) SubCategories
		From	OPENJSON(@jsonData, '$.categories') Category
		union all
		Select	Cast(json_value(SubCategories.[value], '$.id') as int) Id, 
				Cast(json_value(SubCategories.[value], '$.parentId') as int) ParentId, 
				Cast(json_value(SubCategories.[value], '$.name') as nvarchar(max)) Name, 
				Cast(json_query(SubCategories.[value], '$.subCategories') as nvarchar(max)) SubCategories
		From	NestedCategories
			outer apply openjson(NestedCategories.SubCategories) SubCategories
		Where	NestedCategories.SubCategories is not null or NestedCategories.SubCategories <> ''
	)
	Insert Into @Returned(Id, ParentId, Name)
	Select	Id, 
			ParentId, 
			Name
	From	NestedCategories
	Where	Id is not null
	return
END
