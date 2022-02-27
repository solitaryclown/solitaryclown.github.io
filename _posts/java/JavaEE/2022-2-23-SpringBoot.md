---
layout: post
date: 2022-02-23 10:41:57 +0800
author: solitaryclown
title: Spring Boot
categories: Java
tags: Spring
# permalink: /:categories/:title.html
excerpt: "Spring Boot的使用与配置"
---
* content
{:toc}


# 1. Spring boot
## 1.1. 介绍
spring boot是spring官方为简化spring项目的构建和配置，以“约定大于配置”为原则而开发的一个Spring高层应用。使用spring boot，不需要给出任何配置即可快速开发运行一个spring项目。
## 1.2. 入门
### 1.2.1. hello
使用spring boot开发spring项目的步骤如下（以maven工程为例）：
1. 设置pom.xml的`<parent></parent>`元素
   ```xml
   <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.0.1.RELEASE</version>
    </parent>
   ```
2. 导入项目所需的依赖，这些依赖一般是单独用于boot应用，如web工程，只需要导入一个spring-boot-starter-web依赖。
3. 创建boot引导类，调用`SpringApplication.run()`启动项目，这个方法返回一个`ConfigurableApplicationContext`类型的上下文对象。
    ```java
    @SpringBootApplication(scanBasePackages = {"com.hb.contoller"})
    public class MainApplication {
        public static void main(String[] args) {
            SpringApplication.run(MainApplication.class,args);
        }
    }
    ```
**注意**：Spring boot的启动引导类一般放在和源码中其他的包同级目录下，则引导类的`@SpringBootApplication`注解可以不需配置包扫描，否则需要配置扫描的包。

### 1.2.2. boot项目打包成可执行jar包
1. 在pom.xml中引入相关插件
   ```xml
     <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>
    </plugins>
   ```
2. mvn package
3. `java -jar 文件名称`执行

## 1.3. spring boot特性
#### 1.3.0.1. 依赖管理

1. spring-boot-dependencies<br>
每个spring boot项目都要继承spring-boot-starter-parent，这个项目是用来管理插件和配置文件的，而它继承了spring-boot-dependencies项目，这个项目才是SpringBoot用来做依赖管理的，它里面定义了spring项目主流的**依赖版本**（不引入依赖，只是定义依赖的版本，不同的SpringBoot版本定义的依赖版本可能不同）。

2. starter<br>
如果要在项目中引入相关依赖，只需要引入springboot为不同的功能定义的starter就能完成依赖引入的功能，项目名诸如`spring-boot-starter-*`的项目都是springboot官方提供的启动依赖，比如web项目引入spring-boot-starter-web，就能把web相关的依赖引入，如spring容器、springmvc、内置tomcat等。
#### 1.3.0.2. 自动配置
springboot对所有的组件都有一份默认的配置，初始不需要任何配置就能正常启动springboot项目，如果需要自定义配置，只需要在项目资源文件夹下创建`application.*`（后缀可以是propeties、yml或yaml），在配置文件中声明对应的参数就可以让项目中的组件以自定义参数运行。

## 1.4. 注解配置

### 1.4.1. 组件配置

1. `@Configuration`：标识一个生产Bean实例的类
2. `@Bean`：标识返回Bean实例的方法，配置在`@Configuration`标识的方法中。
   **注意**：如果方法有参数，参数值会自动从上下文容器中获取。
3. `@Import`：since 3.0. 标识要引入的一个或多个组件类，通常是`@Configuration`标识的类。也可以是ImportSelector接口、ImportBeanDefinitionRegistrar接口的实现类。如果要引入外部XML文件，请使用`@ImportResource`注解。
4. `@Conditional`：Spring提供了Conditional注解用以Bean实例的条件装配，即只有满足注解条件时Bean才会被装配，这个注解不够方便，Spring Boot提供了这个注解的很多派生注解，名称为`@ConditionalOnXXX`，可以。
   **注意**：条件注解的条件只能匹配到目前为止应用程序上下文处理过的bean定义。强烈建议只在自动配置类上使用该条件。拿@ConditionalOnBean为例，如果候选bean可能由另一个自动配置创建，请确保使用此条件的bean在后面运行。
5. `@ImportResource`：引入bean definition XML形式配置文件。

### 1.4.2. 属性绑定（注入）
1. `@ConfigurationProperties`：boot提供的注解，可以配和`@Component`或`@Bean`使用，作用是为一个组件注入属性值，这个注解告诉boot从application配置文件中找到参数注入当前Bean，前提是这个Bean必须提供getter/setter方法。注解**必须**配置一个prefix指定参数前缀。
   例子：
   ```properties

    #application.properties中自定义属性值
    usr.id=1
    usr.name=solitaryclown
   ```

   ```java
    @Configuration
    public class ComponentConfiguration {

        @Bean("user")
        @ConfigurationProperties(prefix = "usr")
        public User user(){
            return new User();
        }
    }
   ```
   在项目启动后，user组件会被自动注入参数值。
   
2. `@EnableConfigurationProperties(Class<?>[] value())`：如果@ConfigurationProperties注解定义在类上，则要么配合组件注解如@Component，要么使用使用此注解使生效。如果bean没有声明组件注解，意味着不会被装配到IOC容器，但此注解可以让bean自动装配到容器并进行属性注入。此注解可以声明在启动类上，一般是用于非本项目组件的属性注入。

#### 1.4.2.1. boot是怎么自动装配组件的？
1. 组件装配
org.springframework.boot.autoconfigure包是boot自动装配的核心，里面有大量的XXXAutoConfiguration类，用来装配组件，且用了大量的@ConditionalOnXXX进行条件装配。

2. 属性值注入
boot将每个组件的属性都抽取出来分别为XXXProperties，且用了`@ConfigurationProperty`注解进行属性值和配置文件绑定。
在XXXAutoConfiguration类上使用`@EnableConfigurationProperties`关联XXXProperties类（这个注解上面说过，有两个作用，一是注册为容器中的bean，二是属性值自动注入），然后在配置类中使用@Bean方法将返回值交给容器，方法的参数一般会带XXXProperties以此获得实例的参数。

#### 1.4.2.2. 例子：spring mvc的DispatcherServlet的自动装配
在传统Spring项目中，需要在web.xml文件中配置MVC的DispatcherServlet；在boot项目中，org.springframework.boot.autoconfigure.web.servlet.DispatcherServletAutoConfiguration这个类提供了DispatcherServlet的装配。


![dispatcherServlet装配](https://s4.ax1x.com/2022/02/24/bin3ng.png)

WebProperties类：

![dispatcher属性值获取](https://s4.ax1x.com/2022/02/24/binljS.png)

TIPS：application.properties中配置:debug=true可以查看Spring boot的debug信息，包括启动后的bean装配信息。

## 1.5. 配置文件
boot的项目配置文件以application为文件名，后缀可以是propeties或yaml、yml。
在以数据为中心的配置下，使用yml比propertis更简洁。

### 1.5.1. spring-boot-configuration-processor
spring-boot-configuration-processor是一个注释处理器，它生成应用程序中被@ConfigurationProperties注释的类的元数据。您的IDE (Eclipse、IntelliJ或NetBeans)使用该元数据在编辑应用程序时为属性提供自动完成和文档。
<https://stackoverflow.com/questions/53707080/what-is-the-spring-boot-configuration-processor-why-do-people-exclude-librarie>

在pom.xml中引入这个依赖可以在配置时智能提示，对项目运行无影响，因此一般在打包时排除这个依赖：
```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
        <excludes>
            <exclude>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-configuration-processor</artifactId>
            </exclude>
        </excludes>
    </configuration>
</plugin>
```

## 1.6. boot开发web项目
### 1.6.1. 静态资源访问
默认情况下,boot提供了四个存放静态资源的目录：
- /static
- /public
- /resources
- /META-INF/resources

当静态资源放在项目类根目录下的这些目录或者子目录中时，都可以被访问到（如果位于子文件夹要加上子文件夹的名称）。

1. 自定义访问路径：
2. 自定义静态资源存放目录：
```yaml
spring:
  mvc:
    #静态资源访问路径
    static-path-pattern: /static/**
  web:
    resources:
    #静态资源存放目录（数组）
      static-locations: ["classpath:/dir/"]
```

#### 1.6.1.1. 首页
访问boot项目的根路径时，首先在静态资源中寻找index.html作为welcome page
#### 1.6.1.2. icon
命名为favicon.ico，放在静态资源目录下


### 1.6.2. Restful API请求设置
tomcat原生不支持Restful风格的请求，即只允许GET和POST请求，而Restful风格有多种请求，比如GET、POST、PUT、DELETE等。在浏览器中，from表单请求只有get和post，除Get以外的请求都会自动变成Post请求，如果使用其他的请求方式，，**客户端，如果是页面表单请求或者ajax请求，都必须携带一个请求参数，名称为"_method"，值为请求方式，如_method=PUT，服务器端SpringMVC需要配置HiddenMethodFilter来解析这个_method参数**，如果是Postman之类的支持8种请求方式的http请求客户端，则不需要配置HiddenHttpMethodFilter了，因为可以请求头直接有请求方式，SpringMVC可以直接获取。
application.yml
```yml
spring:
  mvc:
    hiddenmethod:
      filter:
        enabled: true
```

表单域：
```html
<!-- 表单的method属性必须为post -->
<form action="请求路径" method="post">
    <!--隐藏参数，指定请求方法名-->
    <input type="hidden" name="_method" value="PUT">
    <input type="submit" value="put请求">
</form>
```

#### 1.6.2.1. 原理
当SpringMVC的HiddenMethodFilter接收到POST请求，会解析其中的_method参数最终把request包装成_method指定请求参数的请求包装类，最终Controller就能通过对应的注解接收不同请求方式的请求。

![HiddenHttpMethodFilter_1](https://s4.ax1x.com/2022/02/24/bkKypn.png)
![HttpRequest包装类](https://s4.ax1x.com/2022/02/24/bkKrfs.png)

boot自动装配：
![boot自动装配HiddenHttpMethodFilter](https://s4.ax1x.com/2022/02/24/bkMFnf.png)

在SpringMVC中，请求参数"_method"这个名称是固定的，如果要自定义，可以直接继承HiddenHttpMethodFilter自定义参数名，并且通过父类提供的set方法进行设置：
```java
/**
	 * Set the parameter name to look for HTTP methods.
	 * @see #DEFAULT_METHOD_PARAM
	 */
	public void setMethodParam(String methodParam) {
		Assert.hasText(methodParam, "'methodParam' must not be empty");
		this.methodParam = methodParam;
	}

```

### 1.6.3. spring mvc请求映射的原理
spring mvc中的DispatcherServlet类的`protected void doDispatch(HttpServletRequest request, HttpServletResponse response)`是处理每个请求的方法。

在DispathcerServlet类中有个属性叫handlerMappings，是一个List类型的集合，保存了不同的HandlerMapping对象，在boot项目中，默认有5个HandlerMapping，boot实现welcome-page配置的原理就是实现了一个WelcomePageHandlerMapping：
![handlerMappings](https://s4.ax1x.com/2022/02/25/bk8Cex.png)

而我们的项目中的Controller中的@RequestMapping方法和映射路径则是注册到了`RequestMappingHandlerMapping`类中
![RequestMappingHandlerMapping](https://s4.ax1x.com/2022/02/25/bk8Pw6.png)




请求映射的核心流程：
DispatcherServet——DS
HandlerMapping——HM

`DS.doservice()`--->`DS.doDispatch()`--->`DS.getHandler()`--->`HM.getHandler()`--->`HM.getHandlerInternal()`


在boot的自动配置包中，WebMvcAutoConfiguraiton类自动注册了RequestMappingHandlerMapping和WelcomeHandlerMapping：
```java
@Bean
@Primary
@Override
public RequestMappingHandlerMapping requestMappingHandlerMapping(
		@Qualifier("mvcContentNegotiationManager") ContentNegotiationManager contentNegotiationManager,
@Qualifier("mvcConversionService") FormattingConversionService conversionService,
@Qualifier("mvcResourceUrlProvider") ResourceUrlProvider resourceUrlProvider) {
// Must be @Primary for MvcUriComponentsBuilder to work
return super.requestMappingHandlerMapping(contentNegotiationManager, conversionService,
		resourceUrlProvider);

@Bean
public WelcomePageHandlerMapping welcomePageHandlerMapping(ApplicationContext applicationContext,
		FormattingConversionService mvcConversionService, ResourceUrlProvider mvcResourceUrlProvider) {
	WelcomePageHandlerMapping welcomePageHandlerMapping = new WelcomePageHandlerMapping(
			new TemplateAvailabilityProviders(applicationContext), applicationContext, getWelcomePage(),
			this.mvcProperties.getStaticPathPattern());
	welcomePageHandlerMapping.setInterceptors(getInterceptors(mvcConversionService, mvcResourceUrlProvider));
	welcomePageHandlerMapping.setCorsConfigurations(getCorsConfigurations());
	return welcomePageHandlerMapping;
}
```

如果项目中有需求，可以自定义HandlerMapping类，编写自己的映射处理逻辑。


### 1.6.4. 请求参数绑定
1. @PathVariable：获取请求路径中参数
2. @RequestParam：获取GET请求参数，即请求url"?"后面的参数值，如果
3. @RequestHeader：获取请求头参数
4. @CookiValue：获取某个cookie
5. @RequestBody：获取请求体的参数
6. @RequestAttribute：获取request域中的数据
7. @MatrixVariale：获取矩阵参数，形如/path;age=xxx;like=1,2,3,age和like这里就是MatrixVariable，参数以分号作为分隔符，如果要获取一个MatrixVariable，必须和PathVariable变量进行绑定，从url上来说，一个MatrixVariable是一个PathVariable的一部分，可以看做附属关系。
   **注意**：在SpringMVC中，MatrixVariale默认是不起作用的，因为默认的路径解析器将路径中的分号部分移除了，如果要获取MatrixVariable，要更改WebMvcConfigure，将路径解析器中的分号去除设置为false：
   ```java
   @Configuration
    public class WebMvcConfig {
        @Bean
        public WebMvcConfigurer webMvcConfigurer(){
            return new WebMvcConfigurer() {
                @Override
                public void configurePathMatch(PathMatchConfigurer configurer) {
                    UrlPathHelper helper = new UrlPathHelper();
                    //分号去除设置为false
                    helper.setRemoveSemicolonContent(false);
                    configurer.setUrlPathHelper(helper);
                }
            };
        }
    }
   ```


#### 1.6.4.1. MVC参数绑定的原理
DispatcherServlet.getHandler()--->getHandlerAdapter()--->HA.handle()--->参数解析

#### 1.6.4.2. 自定义converter
```java
@Slf4j
@Configuration
public class WebMvcConfig {
    @Bean
    public WebMvcConfigurer webMvcConfigurer(){

        return new WebMvcConfigurer() {
             {
                log.info("创建了自定义的WebMvcConfigurer...");
            }
            @Override
            public void configurePathMatch(PathMatchConfigurer configurer) {
                UrlPathHelper helper = new UrlPathHelper();
                helper.setRemoveSemicolonContent(false);
                configurer.setUrlPathHelper(helper);
            }

            @Override
            public void addFormatters(FormatterRegistry registry) {
                log.info("执行了addFormatters()方法..");
                Converter<String, Date> StringToDate = new Converter<String, Date>() {
                    @Override
                    public Date convert(String source) {
                        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                        if(!StringUtils.isEmpty(source)){
                            try {
                                return sdf.parse(source);
                            } catch (ParseException e) {
                                e.printStackTrace();
                            }
                        }
                        return null;
                    }
                };
                registry.addConverter(StringToDate);
            }
        };
    }

}

```



### 1.6.5. 返回值处理（@ResponseBody）
和参数绑定使用参数解析器一样，SpringMVC会对返回值进行类型判断，找到一个合适的返回值处理器对返回值进行处理。
对于标注了`@ResponseBody`的方法或者类，方法的返回值由RequestResponseBodyProcessor这个类处理：
```java
@Override
	public void handleReturnValue(@Nullable Object returnValue, MethodParameter returnType,
			ModelAndViewContainer mavContainer, NativeWebRequest webRequest)
			throws IOException, HttpMediaTypeNotAcceptableException, HttpMessageNotWritableException {

		mavContainer.setRequestHandled(true);
		ServletServerHttpRequest inputMessage = createInputMessage(webRequest);
		ServletServerHttpResponse outputMessage = createOutputMessage(webRequest);

		// Try even with null return value. ResponseBodyAdvice could get involved.
		writeWithMessageConverters(returnValue, returnType, inputMessage, outputMessage);
	}
```


**注意**：对于@ResponseBody的方法，返回值处理器处理后返回的ModelAndView返回值为null，后面执行processDispatchResult()时不会执行视图解析过程。
#### 1.6.5.1. HttpMessageConverter原理
![HttpMessageConverter](https://s4.ax1x.com/2022/02/25/bE2ePO.png)
@ResponseBody的返回值由RequestResponseBodyProcessor这个类处理，但核心是由消息转换器将返回值类型转换成MIME类型。

每个HttpMessageConverter实现都有一个或几个相关的MIME类型。当接收到一个新请求时，Spring将使用“Accept”报头来确定它需要响应的媒体类型。然后，它将尝试找到一个能够处理特定媒体类型的注册转换器。

#### 1.6.5.2. 内容协商
Http请求头中有一个参数Accept，指定了客户端想要接收的响应数据的MIME类型：
![Accept请求头](https://s4.ax1x.com/2022/02/25/bEzUsA.png)

服务器接收到响应后，响应客户端需要的最佳的MIME类型就叫内容协商。
SpringMVC很好地支持了内容协商机制，它是在Controller的方法执行之后，响应返回之前执行的，它的过程是这样的：
1. 判断响应头是否已经设置MIME类型
2. 获取request的Accept字段，查看客户端支持的响应数据类型
3. 遍历所有的messageConverter，看哪个消息转换器支持当前方法的返回值类型的处理
   如果某个messageConverter支持当前返回值类型的处理，记录这个消息转换器支持的所有MIME类型。（加入一个List）
4. 根据某些策略选择一个最佳的消息转换器进行消息转换。

如果项目中同时导入了xml和json的消息转换器依赖且如果http客户端的Accept中xml比json权重高，MVC会使用消息转换器将返回值序列化为XML形式的数据最终响应给客户端，而如果服务器没有客户端请求的MIME类型，会返回406——Not Acceptable：

![accept xml](https://s4.ax1x.com/2022/02/26/bVKCUU.png)
![accept json](https://s4.ax1x.com/2022/02/26/bVK9ET.png)
![accept html](https://s4.ax1x.com/2022/02/26/bVKSbV.png)

##### 1.6.5.2.1. 内容协商策略
在服务器进行内容协商时，会使用一个策略管理器ContentNegotiationManager，策略管理器会遍历所有的内容协商策略类（ContentNegotiationStrategy）来获取此次http请求需要的响应数据的MIME类型。

**内容协商策略**即服务器判断请求内容的依据，SpringMVC提供了多种内容协商策略，默认是按照http请求头的Accept参数来进行响应类型的选择，即HeaderContentNegotiationStrategy，此外，SpringMVC还有一种策略叫参数内容协商策略：ParameterContentNegotiationStrategy，如果使用内容协商策略，那么在http请求时需要携带一个参数“format”，它的值是请求需要的MIME类型，服务器会根据参数协商策略获取format的值得到http请求需要的MIME类型，从而响应数据。

ParameterContentNegotiationStrategy默认是不启用的，如果要开启，设置`spring.mvc.contentnegotiation.favor-parameter=true`

![format=xml](https://s4.ax1x.com/2022/02/26/bV0F0S.png)
![format=json](https://s4.ax1x.com/2022/02/26/bV0kTg.png)

##### 1.6.5.2.2. 自定义messageConverter



### 1.6.6. 返回值处理（视图名）
前面提到SpringMVC会根据Controller方法的返回值类型，寻找合适的返回值处理器进行处理，SpringMVC共有15种返回值处理器：
![返回值处理器](https://s4.ax1x.com/2022/02/27/bmdBm6.png)


前面提到了SpringMVC对于标注了@ResponseBody的方法的返回值的处理，现在谈谈返回视图名的处理。
ViewNameMethodReturnValueHandler用来处理没有标注@ResponseBody且返回一个String类型的返回值的方法。

View是SpringMVC定义的一个视图接口，它表示被一个ViewResolver解析和初始化后将要执行的模板。

1. 对于返回视图名的方法，ViewNameMethodReturnValueHandler对返回值进行处理后会返回一个ModelAndView对象mv，最终由给处理器适配器的handle()方法返回到doDispatch中
    ![](https://s4.ax1x.com/2022/02/27/bmfIYR.png)
2. 调用processDispatchResult()对mv进行处理
   ![](https://s4.ax1x.com/2022/02/27/bmfjTH.png)
3. render(mv,req,resp)，对mv进行渲染处理，但只是一个逻辑，还没有真正执行视图渲染，因为此时。
   ![](https://s4.ax1x.com/2022/02/27/bmfX0e.png)
4. resolveViewName()，根据视图名遍历所有的viewResolver，如果有一个视图解析器能正确解析出一个View对象，立即返回
   ![](https://s4.ax1x.com/2022/02/27/bmfxkd.png)
   ![](https://s4.ax1x.com/2022/02/27/bmfztA.png)
5. 调用view.resolve(model,req,resp)进行真正的视图渲染，即把响应数据写到resp的过程。
    ![](https://s4.ax1x.com/2022/02/27/bmfOmD.png)
    ![](https://s4.ax1x.com/2022/02/27/bmhSfI.png)




### 1.6.7. 拦截器
SpringMVC的拦截器类似于javax.servlet.Filter，应用包括对访问资源做权限控制、统一视图控制、统一异常处理等。
#### 1.6.7.1. 使用

这里以用来做访问控制的拦截器为例：当客户端未登录时，访问登录接口以及静态资源以外的资源都不会被拦截器放行。
1. 创建拦截器类，继承HandlerInterceptor接口，重写方法
   ```java
    public class LoginInterceptor implements HandlerInterceptor {
        @Override
        public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
            Object loginUser = request.getSession().getAttribute("loginUser");
            if(loginUser==null){
                response.sendRedirect("/login");
                return false;
            }else {
                return true;
            }
        }

        @Override
        public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {

        }

        @Override
        public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {

        }
    }

   ```
2. 注册拦截器
   ```java
    @Configuration
    public class InterceptroConfig implements WebMvcConfigurer {
        @Override
        public void addInterceptors(InterceptorRegistry registry) {
            InterceptorRegistration interceptorRegistration = registry.addInterceptor(new LoginInterceptor());
            // /**会拦截所有资源，包括静态资源，需要排除
            String[] excludes = {
                    "/", "/login",
                    "/css/**",
                    "/images/**",
                    "/js/**",
                    "/fonts/**"
            };

            interceptorRegistration.
                    addPathPatterns("/**").
                    excludePathPatterns(excludes);

        }
    }
   ```

#### 1.6.7.2. 原理
在DispatcherServlet.doDispatch()中会为请求获取一个HandlerExecutionChain对象，它包含一个当前可以处理当前请求的handler和一个拦截器集合。
拦截器的过程是这样的：
1. 在执行请求方法前执行interceptor集合中每个拦截器的preHandle()，如果某个拦截器的preHandle返回false，直接触发afterCompletion()。HandlerExecutionChain中维护一个interceptorIndex，记录了当前preHandle()方法返回true的最后一个拦截器（意味着从第一个拦截器开始到interceptorIndex位置的拦截器，preHandle()都返回了true），从这个拦截器开始的afterCompletion()开始执行，一直执行到第一个拦截器的afterCompletion()。且拦截器链中只要有一个拦截器的preHandle()返回false，DispatchServlet的`doDispatch()`会直接返回，不会执行请求的资源。

2. 执行请求方法
3. 执行请求方法之后执行interceptor集合中每个拦截器的postHandle(),从最后一个位置的拦截器开始往前执行每个拦截器的postHandle()
4. 调用processDispatchResult()进行视图渲染，这个方法的最后会触发拦截器链的`triggerAfterCompletion()`。

SpringMVC对异常的处理保证了HandlerExecutionChain的`triggerAfterCompletion()`方法一定会被执行。


[![bnBWMd.png](https://s4.ax1x.com/2022/02/27/bnBWMd.png)](https://imgtu.com/i/bnBWMd)
[![bnB2xH.png](https://s4.ax1x.com/2022/02/27/bnB2xH.png)](https://imgtu.com/i/bnB2xH)
[![bnBfsA.png](https://s4.ax1x.com/2022/02/27/bnBfsA.png)](https://imgtu.com/i/bnBfsA)