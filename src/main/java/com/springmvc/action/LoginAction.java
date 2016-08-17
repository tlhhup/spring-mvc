package com.springmvc.action;

import java.util.HashMap;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

import com.springmvc.entity.User;

@Controller
@RequestMapping("/LoginAction")
public class LoginAction {

	@RequestMapping(value="/login",method=RequestMethod.POST)
	public String login(User user){
		return "main";
	}
	
	@RequestMapping("/loginJson")
	@ResponseBody
	public Map<?, ?> loginJson(@RequestBody User user){
		Map<String, Object> result=new HashMap<>();
		result.put("flag", true);
		result.put("msg", "登录成功");
		return result;
	}
	
}
