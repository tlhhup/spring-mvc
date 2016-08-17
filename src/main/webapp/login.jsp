<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link href="resources/css/bootstrap.min.css" rel="stylesheet">
<script src="resources/js/jquery-1.11.3.min.js"
	type="application/javascript"></script>
<script src="resources/js/bootstrap.min.js"
	type="application/javascript"></script>
<script type="text/javascript">
	function login(){
		$.ajax({
			url:'LoginAction/loginJson.do',
			type:'POST',
			contentType:"application/json",
			data:'{"userName":"'+$("#inputEmail3").val()+'","password":"'+$("#inputPassword3").val()+'"}',
			dataType:'json',
			success:function(data){
				console.info(data);
			}
		});
	}
</script>
<title>用户登录</title>
</head>
<body>
	<div class="container">
		<form id="loginForm" class="form-horizontal" action="LoginAction/login.do" method="post">
			<div class="form-group has-error">
				<label for="inputEmail3" class="col-sm-2 control-label">用户名:</label>
				<div class="col-sm-10">
					<input type="text" name="userName" class="form-control" id="inputEmail3"
						placeholder="请输入用户名">
				</div>
			</div>
			<div class="form-group has-error">
				<label for="inputPassword3" class="col-sm-2 control-label">密&nbsp;&nbsp;码:</label>
				<div class="col-sm-10">
					<input type="password" name="password" class="form-control" id="inputPassword3"
						placeholder="请输入密码">
				</div>
			</div>
			<div class="form-group">
				<div class="col-sm-offset-2 col-sm-10" align="center">
					<input type="submit" class="btn btn-default" value="登录">&nbsp;&nbsp;
					<input type="button" class="btn btn-default" value="Ajax登录" onclick="login();">&nbsp;&nbsp;
					<input type="reset" class="btn btn-default" value="重置">
				</div>
			</div>
		</form>
	</div>
</body>
</html>