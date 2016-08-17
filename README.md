# spring-mvc
ajax请求返回json数据

注意事项

1. 使用springmvc4.2时返回json数据需要引入jackson的jar包，因为springmvc对json数据的转换时通过MappingJackson2JsonView来处理的，而从源码中可以看到如下信息

	![](http://i.imgur.com/OQGZvJo.png)

	使用的是jackson提供的类，需要引入以下的jar包

		<dependency>
			<groupId>com.fasterxml.jackson.core</groupId>
			<artifactId>jackson-core</artifactId>
			<version>2.7.3</version>
		</dependency>
		<dependency>
			<groupId>com.fasterxml.jackson.core</groupId>
			<artifactId>jackson-databind</artifactId>
			<version>2.7.3</version>
		</dependency>
		<dependency>
			<groupId>com.fasterxml.jackson.core</groupId>
			<artifactId>jackson-annotations</artifactId>
			<version>2.7.3</version>
		</dependency>
		<dependency>
			<groupId>com.fasterxml.jackson.module</groupId>
			<artifactId>jackson-module-jaxb-annotations</artifactId>
			<version>2.7.3</version>
		</dependency>

2. 在spring3.1之前需要配置messageconvertors对json数据进行转换，在使用spring3.1之后的版本只需要在springmvc的配置文件中添加如下配置即可

		<!-- 模型驱动 -->
		<mvc:annotation-driven />
3. **在返回json格式的数据的时候**，springmvc的请求的后缀不能为.html或.htm，不然即是添加了@ResponseBody注解也会报406的错误，其主要原因在于源码中处理json数据是会调用`AbstractMessageConverterMethodProcessor.writeWithMessageConverters`该方法，会对请求获取的content-type和返回的content-type进行匹配，然而如果请求的后缀为.html或.htm获取的请求的所支持的数据类型都为`text/html`，无法匹配json类型的数据，则报406的错误

		Class<?> returnValueClass = getReturnValueType(returnValue, returnType);
		Type returnValueType = getGenericType(returnType);
		HttpServletRequest servletRequest = inputMessage.getServletRequest();
		//获取请求支持的数据类型
		List<MediaType> requestedMediaTypes = getAcceptableMediaTypes(servletRequest);
		//获取响应的数据类型
		List<MediaType> producibleMediaTypes = getProducibleMediaTypes(servletRequest, returnValueClass, returnValueType);

		if (returnValue != null && producibleMediaTypes.isEmpty()) {
			throw new IllegalArgumentException("No converter found for return value of type: " + returnValueClass);
		}
		//进行匹配，如果有匹配加入到compatibleMediaTypes集合中
		Set<MediaType> compatibleMediaTypes = new LinkedHashSet<MediaType>();
		for (MediaType requestedType : requestedMediaTypes) {
			for (MediaType producibleType : producibleMediaTypes) {
				if (requestedType.isCompatibleWith(producibleType)) {
					compatibleMediaTypes.add(getMostSpecificMediaType(requestedType, producibleType));
				}
			}
		}
		if (compatibleMediaTypes.isEmpty()) {
			if (returnValue != null) {
				//类型不支持异常
				throw new HttpMediaTypeNotAcceptableException(producibleMediaTypes);
			}
			return;
		}
4. springmvc的执行流程(通过注解方式)
	1. 先调用`DispatcherServlet.doDispatch(HttpServletRequest,HttpServletResponse)`,获取指定的处理器映射器，在通过该映射器获取处理器适配器决定调用的方法

			// Determine handler for the current request.获取映射器
			mappedHandler = getHandler(processedRequest);
			if (mappedHandler == null || mappedHandler.getHandler() == null) {
				noHandlerFound(processedRequest, response);
				return;
			}

			// Determine handler adapter for the current request.获取处理器适配器
			HandlerAdapter ha = getHandlerAdapter(mappedHandler.getHandler());

			....

			// Actually invoke the handler. 处理器适配调用，返回modelandview
			mv = ha.handle(processedRequest, response, mappedHandler.getHandler());
	2. 调用`AbstractHandlerMethodAdapter.handle(HttpServletRequest, HttpServletResponse, Object)`方法

			public final ModelAndView handle(HttpServletRequest request, HttpServletResponse response, Object handler)
					throws Exception {
		
				return handleInternal(request, response, (HandlerMethod) handler);
			}
	3. 调用`RequestMappingHandlerAdapter.handleInternal(HttpServletRequest, HttpServletResponse, HandlerMethod)`方法

			protected ModelAndView handleInternal(HttpServletRequest request,
				HttpServletResponse response, HandlerMethod handlerMethod) throws Exception {
				...
		
				mav = invokeHandlerMethod(request, response, handlerMethod);
				...
		
				return mav;
			}
	4. 调用`RequestMappingHandlerAdapter.invokeHandlerMethod(HttpServletRequest, HttpServletResponse, HandlerMethod)`方法

			protected ModelAndView invokeHandlerMethod(HttpServletRequest request,HttpServletResponse response, HandlerMethod handlerMethod) throws Exception {
				
				ServletInvocableHandlerMethod invocableMethod = createInvocableHandlerMethod(handlerMethod);
				...
				//调用方法
				invocableMethod.invokeAndHandle(webRequest, mavContainer);
				...
				//获取视图
				return getModelAndView(mavContainer, modelFactory, webRequest);
			}
	5. 调用`ServletInvocableHandlerMethod.invokeAndHandle(ServletWebRequest, ModelAndViewContainer, Object...)`方法
		
			public void invokeAndHandle(ServletWebRequest webRequest,
				ModelAndViewContainer mavContainer, Object... providedArgs) throws Exception {
				//调用目标方法，这个有点像aop
				Object returnValue = invokeForRequest(webRequest, mavContainer, providedArgs);
				...
				try {
					//处理返回值
					this.returnValueHandlers.handleReturnValue(
							returnValue, getReturnValueType(returnValue), mavContainer, webRequest);
				}
				...
			}
	6. 调用`HandlerMethodReturnValueHandlerComposite.handleReturnValue(Object, MethodParameter, ModelAndViewContainer, NativeWebRequest)`方法

			public void handleReturnValue(Object returnValue, MethodParameter returnType,
					ModelAndViewContainer mavContainer, NativeWebRequest webRequest) throws Exception {
				//选择不同的返回值处理器
				HandlerMethodReturnValueHandler handler = selectHandler(returnValue, returnType);
				...
				handler.handleReturnValue(returnValue, returnType, mavContainer, webRequest);
			}
	7. 如果是json及添加了@ResponseBody注解的方法，则调用`RequestResponseBodyMethodProcessor.handleReturnValue(Object, MethodParameter, ModelAndViewContainer, NativeWebRequest)`方法处理json数据输出
	8. 再调用`AbstractMessageConverterMethodProcessor.writeWithMessageConverters(T, MethodParameter, ServletServerHttpRequest, ServletServerHttpResponse)`方法将json数据输出的body中