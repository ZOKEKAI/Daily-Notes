**1、Dispatcher对象初始化过程**

	public void init(FilterConfig filterConfig) throws ServletException {
		InitOperations init = new InitOperations();
		Dispatcher dispatcher = null;
		try {
			FilterHostConfig config = new FilterHostConfig(filterConfig);
			init.initLogging(config);
			dispatcher = init.initDispatcher(config);
			init.initStaticContentLoader(config, dispatcher);
	
			this.prepare = new PrepareOperations(dispatcher);
			this.execute = new ExecuteOperations(dispatcher);
			this.excludedPatterns = init.buildExcludedPatternsList(dispatcher);
	
			postInit(dispatcher, filterConfig);
		} finally {
			if (dispatcher != null) {
				dispatcher.cleanUpAfterInit();
			}
			init.cleanup();
		}
	}



**2、InitOperations是用于初始化操作的工具类**

```InitOperations init = new InitOperations();```

```
public class InitOperations {
	public void initLogging(HostConfig filterConfig) {
		String factoryName = filterConfig.getInitParameter("loggerFactory");
		if (factoryName == null)
			return;
		try {
			Class cls = ClassLoaderUtil.loadClass(factoryName, super.getClass());
			LoggerFactory fac = (LoggerFactory) cls.newInstance();
			LoggerFactory.setLoggerFactory(fac);
		} catch (InstantiationException e) {
			System.err.println("Unable to instantiate logger factory: " + factoryName + ", using default");
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			System.err.println("Unable to access logger factory: " + factoryName + ", using default");
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			System.err.println("Unable to locate logger factory class: " + factoryName + ", using default");
			e.printStackTrace();
		}
	}

	public Dispatcher initDispatcher(HostConfig filterConfig) {
		Dispatcher dispatcher = createDispatcher(filterConfig);
		dispatcher.init();
		return dispatcher;
	}

	public StaticContentLoader initStaticContentLoader(HostConfig filterConfig, Dispatcher dispatcher) {
		StaticContentLoader loader = (StaticContentLoader) dispatcher.getContainer()
				.getInstance(StaticContentLoader.class);
		loader.setHostConfig(filterConfig);
		return loader;
	}

	public Dispatcher findDispatcherOnThread() {
		Dispatcher dispatcher = Dispatcher.getInstance();
		if (dispatcher == null) {
			throw new IllegalStateException("Must have the StrutsPrepareFilter execute before this one");
		}
		return dispatcher;
	}

	private Dispatcher createDispatcher(HostConfig filterConfig) {
		Map params = new HashMap();
		for (Iterator e = filterConfig.getInitParameterNames(); e.hasNext();) {
			String name = (String) e.next();
			String value = filterConfig.getInitParameter(name);
			params.put(name, value);
		}
		return new Dispatcher(filterConfig.getServletContext(), params);
	}

	public void cleanup() {
		ActionContext.setContext(null);
	}

	public List<Pattern> buildExcludedPatternsList(Dispatcher dispatcher) {
		return buildExcludedPatternsList(
				(String) dispatcher.getContainer().getInstance(String.class, "struts.action.excludePattern"));
	}

	private List<Pattern> buildExcludedPatternsList(String patterns) {
		if ((null != patterns) && (patterns.trim().length() != 0)) {
			List list = new ArrayList();
			String[] tokens = patterns.split(",");
			for (String token : tokens) {
				list.add(Pattern.compile(token.trim()));
			}
			return Collections.unmodifiableList(list);
		}
		return null;
	}
}
```

**3、新建配置文件对象**

```
FilterHostConfig config = new FilterHostConfig(filterConfig);
```

```
public FilterHostConfig(FilterConfig config) {
	this.config = config;
}
```

**4、初始化日志框架**

```
init.initLogging(config);
```

```
public void initLogging(HostConfig filterConfig) {
		String factoryName = filterConfig.getInitParameter("loggerFactory");
		if (factoryName == null)
			return;
		try {
			Class cls = ClassLoaderUtil.loadClass(factoryName, super.getClass());
			LoggerFactory fac = (LoggerFactory) cls.newInstance();
			LoggerFactory.setLoggerFactory(fac);
		} catch (InstantiationException e) {
			System.err.println("Unable to instantiate logger factory: " + factoryName + ", using default");
			e.printStackTrace();
		} catch (IllegalAccessException e) {
			System.err.println("Unable to access logger factory: " + factoryName + ", using default");
			e.printStackTrace();
		} catch (ClassNotFoundException e) {
			System.err.println("Unable to locate logger factory class: " + factoryName + ", using default");
			e.printStackTrace();
		}
	}
```

**5、根据配置文件对象新建dispatcher对象**

```
(1)根据配置文件调用createDispatcher方法新建一个原始的dispatcher对象
    public Dispatcher initDispatcher(HostConfig filterConfig) {
        Dispatcher dispatcher = createDispatcher(filterConfig);
        dispatcher.init();
        return dispatcher;
    }

(2)createDispatcher(filterConfig)方法
    private Dispatcher createDispatcher(HostConfig filterConfig) {
        Map params = new HashMap();
        for (Iterator e = filterConfig.getInitParameterNames(); e.hasNext();) {
            String name = (String) e.next();
            String value = filterConfig.getInitParameter(name);
            params.put(name, value);
        }
        return new Dispatcher(filterConfig.getServletContext(), params);
    }

(3)init()方法使用struts-default.xml,struts-plugin.xml,struts.xml这三个文件，完善dispatcher对象
	public void init() {
		if (this.configurationManager == null) {
			this.configurationManager = createConfigurationManager("struts");
		}
		try {
			init_FileManager();
			
			//加载default.properties
			init_DefaultProperties();
			
            //加载 struts-default.xml,struts-plugin.xml,struts.xml
			init_TraditionalXmlConfigurations();
			
            //加载struts.properties
			init_LegacyStrutsProperties();
			
			//加载我们在struts.xml里面提供的一些类
			init_CustomConfigurationProviders();
			
			//加载在web.xml里面配置的过滤器参数
			init_FilterInitParameters();
			
			//给一些对象起别名
			init_AliasStandardObjects();

			Container container = init_PreloadConfiguration();
			container.inject(this);
			init_CheckWebLogicWorkaround(container);

			if (!(dispatcherListeners.isEmpty())) {
				for (DispatcherListener l : dispatcherListeners) {
					l.dispatcherInitialized(this);
				}
			}
			this.errorHandler.init(this.servletContext);
		} catch (Exception ex) {
			if (LOG.isErrorEnabled())
				LOG.error("Dispatcher initialization failed", ex, new String[0]);
			throw new StrutsException(ex);
		}
	}
```

**6、使用initStaticContentLoader初始化StaticContentLoader对象**

```
init.initStaticContentLoader(config, dispatcher);
```

```
	public StaticContentLoader initStaticContentLoader(HostConfig filterConfig, Dispatcher dispatcher) {
		StaticContentLoader loader = (StaticContentLoader) dispatcher.getContainer()
				.getInstance(StaticContentLoader.class);
		loader.setHostConfig(filterConfig);
		return loader;
	}
```

**7、prepare**

```
this.prepare = new PrepareOperations(dispatcher);
```

**8、execute**

```
this.execute = new ExecuteOperations(dispatcher);
```

**9、使用InitOperations工具类获得被排除的Pattern对象的List集合**

```
this.excludedPatterns = init.buildExcludedPatternsList(dispatcher);
```

```
public List<Pattern> buildExcludedPatternsList(Dispatcher dispatcher) {
	return buildExcludedPatternsList(
			(String) dispatcher.getContainer().getInstance(String.class, "struts.action.excludePattern"));
}

private List<Pattern> buildExcludedPatternsList(String patterns) {
	if ((null != patterns) && (patterns.trim().length() != 0)) {
		List list = new ArrayList();
		String[] tokens = patterns.split(",");
		for (String token : tokens) {
			list.add(Pattern.compile(token.trim()));
		}
		return Collections.unmodifiableList(list);
	}
	return null;
}
```

**10、cleanup()方法用于将Container对象从ThreadLocal**里面移除掉

**11、过滤器执行步骤**

```
	public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
			throws IOException, ServletException {
		HttpServletRequest request = (HttpServletRequest) req;
		HttpServletResponse response = (HttpServletResponse) res;
		try {
		
			//判断该请求是否需要struts2处理，即判断请求路径是否被排除在外
			if ((this.excludedPatterns != null) && (this.prepare.isUrlExcluded(request, this.excludedPatterns))) {
			
				//如果不需要struts2处理直接放行(配置/*表示所有路径均需要处理)
				chain.doFilter(request, response);
			} else {
			
				//设置中文编码
				this.prepare.setEncodingAndLocale(request, response);
				
				//使用request和response创建action数据中心
				this.prepare.createActionContext(request, response);
				this.prepare.assignDispatcherToThread();
				request = this.prepare.wrapRequest(request);
				ActionMapping mapping = this.prepare.findActionMapping(request, response, true);
				if (mapping == null) {
					boolean handled = this.execute.executeStaticResourceRequest(request, response);
					if (!(handled))
						chain.doFilter(request, response);
				} else {
					this.execute.executeAction(request, response, mapping);
				}
			}
		} finally {
			this.prepare.cleanupRequest(request);
		}
	}
```

**11、使用request和response创建action数据中心**

```
this.prepare.createActionContext(request, response);
```

```
	public ActionContext createActionContext(HttpServletRequest request, HttpServletResponse response) {
		Integer counter = Integer.valueOf(1);
		Integer oldCounter = (Integer) request.getAttribute("__cleanup_recursion_counter");
		if (oldCounter != null) {
			counter = Integer.valueOf(oldCounter.intValue() + 1);
		}

		ActionContext oldContext = ActionContext.getContext();
		ActionContext ctx;
		ActionContext ctx;
		if (oldContext != null) {
			ctx = new ActionContext(new HashMap(oldContext.getContextMap()));
		} else {
		
			//创建值栈
			ValueStack stack = ((ValueStackFactory) this.dispatcher.getContainer().getInstance(ValueStackFactory.class))
					.createValueStack();
			stack.getContext().putAll(this.dispatcher.createContextMap(request, response, null));
			ctx = new ActionContext(stack.getContext());
		}
		request.setAttribute("__cleanup_recursion_counter", counter);
		ActionContext.setContext(ctx);
		return ctx;
	}
```

