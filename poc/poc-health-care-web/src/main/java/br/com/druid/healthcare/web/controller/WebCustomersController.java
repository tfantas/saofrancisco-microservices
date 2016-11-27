package br.com.druid.healthcare.web.controller;

import java.util.List;
import java.util.logging.Logger;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.util.StringUtils;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import br.com.druid.healthcare.web.SearchCriteria;
import br.com.druid.healthcare.web.WebAccountsService;
import br.com.druid.healthcare.web.domain.Customer;
import br.com.druid.healthcare.web.service.WebCustomersService;

/**
 * Client controller, fetches Account info from the microservice via
 * {@link WebAccountsService}.
 * 
 * @author Paul Chapman
 */
@Controller
public class WebCustomersController {

	@Autowired
	protected WebCustomersService customersService;

	protected Logger logger = Logger.getLogger(WebCustomersController.class
			.getName());

	public WebCustomersController(WebCustomersService customersService) {
		this.customersService = customersService;
	}

	@InitBinder
	public void initBinder(WebDataBinder binder) {
		binder.setAllowedFields("accountNumber", "searchText");
	}

	@RequestMapping("/customers")
	public String goHome() {
		return "index";
	}

	@RequestMapping("/customers/{customerNumber}")
	public String byNumber(Model model,
			@PathVariable("customerNumber") String customersNumber) {

		logger.info("web-service byNumber() invoked: " + customersNumber);

		Customer customer = customersService.findByNumber(customersNumber);
		logger.info("web-service byNumber() found: " + customer);
		model.addAttribute("customer", customer);
		return "customer";
	}

	@RequestMapping("/customers/owner/{text}")
	public String ownerSearch(Model model, @PathVariable("text") String name) {
		logger.info("web-service byOwner() invoked: " + name);

		List<Customer> customers = customersService.byOwnerContains(name);
		logger.info("web-service byOwner() found: " + customers);
		model.addAttribute("search", name);
		if (customers != null)
			model.addAttribute("customers", customers);
		return "customers";
	}

	@RequestMapping(value = "/customers/search", method = RequestMethod.GET)
	public String searchForm(Model model) {
		model.addAttribute("searchCriteria", new SearchCriteria());
		return "accountSearch";
	}

	@RequestMapping(value = "/customers/dosearch")
	public String doSearch(Model model, SearchCriteria criteria,
			BindingResult result) {
		logger.info("web-service search() invoked: " + criteria);

		criteria.validate(result);

		if (result.hasErrors())
			return "accountSearch";

		String accountNumber = criteria.getAccountNumber();
		if (StringUtils.hasText(accountNumber)) {
			return byNumber(model, accountNumber);
		} else {
			String searchText = criteria.getSearchText();
			return ownerSearch(model, searchText);
		}
	}
}
