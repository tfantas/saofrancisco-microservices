package br.com.druid.healthcare;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.client.loadbalancer.LoadBalanced;
import org.springframework.cloud.netflix.hystrix.EnableHystrix;
import org.springframework.cloud.netflix.hystrix.dashboard.EnableHystrixDashboard;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.web.client.RestTemplate;

import br.com.druid.healthcare.web.HomeController;
import br.com.druid.healthcare.web.WebAccountsController;
import br.com.druid.healthcare.web.WebAccountsService;
import br.com.druid.healthcare.web.controller.WebCustomersController;
import br.com.druid.healthcare.web.service.WebCustomersService;

@SpringBootApplication
@EnableHystrix
@EnableHystrixDashboard
@EnableDiscoveryClient
@ComponentScan(useDefaultFilters = false) // Disable component scanner
public class PocHealthCareWebApplication {

	public static void main(String[] args) {
		SpringApplication.run(PocHealthCareWebApplication.class, args);
	}
	
	/**
	 * URL uses the logical name of account-service - upper or lower case,
	 * doesn't matter.
	 */
	public static final String ACCOUNTS_SERVICE_URL = "http://ACCOUNTS-SERVICE";

	public static final String CUSTOMERS_SERVICE_URL = "http://CUSTOMER";
	
	

	/**
	 * A customized RestTemplate that has the ribbon load balancer build in.
	 * Note that prior to the "Brixton" 
	 * 
	 * @return
	 */
	@LoadBalanced
	@Bean
	RestTemplate restTemplate() {
		return new RestTemplate();
	}

	@Bean
	public WebAccountsService accountsService() {
		return new WebAccountsService(ACCOUNTS_SERVICE_URL);
	}

	@Bean
	public WebAccountsController accountsController() {
		return new WebAccountsController(accountsService());
	}

	@Bean
	public WebCustomersService customersService() {
		return new WebCustomersService(CUSTOMERS_SERVICE_URL);
	}

	@Bean
	public WebCustomersController customerController() {
		return new WebCustomersController(customersService());
	}

	@Bean
	public HomeController homeController() {
		return new HomeController();
	}
}
