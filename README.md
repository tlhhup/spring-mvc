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