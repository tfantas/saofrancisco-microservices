package br.com.druid.healthinsurance.security;

import java.io.IOException;

import org.apache.commons.io.IOUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpMethod;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.oauth2.config.annotation.web.configuration.EnableResourceServer;
import org.springframework.security.oauth2.config.annotation.web.configuration.ResourceServerConfigurerAdapter;
import org.springframework.security.oauth2.config.annotation.web.configurers.ResourceServerSecurityConfigurer;
import org.springframework.security.oauth2.provider.token.DefaultTokenServices;
import org.springframework.security.oauth2.provider.token.TokenStore;
import org.springframework.security.oauth2.provider.token.store.JwtAccessTokenConverter;
import org.springframework.security.oauth2.provider.token.store.JwtTokenStore;

@Configuration
@EnableResourceServer
public class ResourceServerConfiguration extends ResourceServerConfigurerAdapter {

	@Autowired
	private JwtAccessTokenConverter jwtAccessTokenConverter;

	@Override
	public void configure(ResourceServerSecurityConfigurer resources) {
		resources.tokenStore(new JwtTokenStore(jwtAccessTokenConverter));
	}

	@Bean
	public TokenStore tokenStore() {
		return new JwtTokenStore(accessTokenConverter());
	}

	@Bean
	public JwtAccessTokenConverter accessTokenConverter() {
	    JwtAccessTokenConverter converter = new JwtAccessTokenConverter();
	    Resource resource = new ClassPathResource("public.txt");
	    String publicKey = null;
	    try {
	        publicKey = IOUtils.toString(resource.getInputStream());
	    } catch (final IOException e) {
	        throw new RuntimeException(e);
	    }
	    converter.setVerifierKey(publicKey);
	    return converter;
	}

	@Bean
	@Primary
	public DefaultTokenServices tokenServices() {
		DefaultTokenServices defaultTokenServices = new DefaultTokenServices();
		defaultTokenServices.setTokenStore(tokenStore());
		return defaultTokenServices;
	}
	
	@Override
	public void configure(HttpSecurity http) throws Exception {
		// @formatter:off
		http
			.csrf().disable().authorizeRequests()
                .antMatchers(HttpMethod.GET, "/services/access-control/**").hasAuthority("ACCESS_CONTROL_READ")
                .antMatchers(HttpMethod.POST, "/services/access-control/**").hasAuthority("ACCESS_CONTROL_WRITE")
                .antMatchers(HttpMethod.PUT, "/services/access-control/**").hasAuthority("ACCESS_CONTROL_WRITE")
                .antMatchers(HttpMethod.PATCH, "/services/access-control/**").hasAuthority("ACCESS_CONTROL_WRITE")
                .antMatchers(HttpMethod.DELETE, "/services/access-control/**").hasAuthority("ACCESS_CONTROL_WRITE")

		        .antMatchers(HttpMethod.GET, "/services/company/**").hasAuthority("COMPANY_READ")
                .antMatchers(HttpMethod.POST, "/services/company/**").hasAuthority("COMPANY_WRITE")
                .antMatchers(HttpMethod.PUT, "/services/company/**").hasAuthority("COMPANY_WRITE")
                .antMatchers(HttpMethod.PATCH, "/services/company/**").hasAuthority("COMPANY_WRITE")
                .antMatchers(HttpMethod.DELETE, "/services/company/**").hasAuthority("COMPANY_WRITE")

                .antMatchers(HttpMethod.GET, "/services/beneficiary/**").hasAuthority("BENEFICIARY_READ")
                .antMatchers(HttpMethod.POST, "/services/beneficiary/**").hasAuthority("BENEFICIARY_WRITE")
                .antMatchers(HttpMethod.PUT, "/services/beneficiary/**").hasAuthority("BENEFICIARY_WRITE")
                .antMatchers(HttpMethod.PATCH, "/services/beneficiary/**").hasAuthority("BENEFICIARY_WRITE")
                .antMatchers(HttpMethod.DELETE, "/services/beneficiary/**").hasAuthority("BENEFICIARY_WRITE")

                .antMatchers(HttpMethod.GET, "/services/contract/**").hasAuthority("CONTRACT_READ")
                .antMatchers(HttpMethod.POST, "/services/contract/**").hasAuthority("CONTRACT_WRITE")
                .antMatchers(HttpMethod.PUT, "/services/contract/**").hasAuthority("CONTRACT_WRITE")
                .antMatchers(HttpMethod.PATCH, "/services/contract/**").hasAuthority("CONTRACT_WRITE")
                .antMatchers(HttpMethod.DELETE, "/services/contract/**").hasAuthority("CONTRACT_WRITE")

                .antMatchers(HttpMethod.GET, "/services/address/**").hasAuthority("ADDRESS_READ")
                .antMatchers(HttpMethod.POST, "/services/address/**").hasAuthority("ADDRESS_WRITE")
                .antMatchers(HttpMethod.PUT, "/services/address/**").hasAuthority("ADDRESS_WRITE")
                .antMatchers(HttpMethod.PATCH, "/services/address/**").hasAuthority("ADDRESS_WRITE")
                .antMatchers(HttpMethod.DELETE, "/services/address/**").hasAuthority("ADDRESS_WRITE")

                .antMatchers(HttpMethod.GET, "/services/document/**").hasAuthority("DOCUMENT_READ")
                .antMatchers(HttpMethod.POST, "/services/document/**").hasAuthority("DOCUMENT_WRITE")
                .antMatchers(HttpMethod.PUT, "/services/document/**").hasAuthority("DOCUMENT_WRITE")
                .antMatchers(HttpMethod.PATCH, "/services/document/**").hasAuthority("DOCUMENT_WRITE")
                .antMatchers(HttpMethod.DELETE, "/services/document/**").hasAuthority("DOCUMENT_WRITE")

                .antMatchers(HttpMethod.GET, "/services/billing/**").hasAuthority("BILLING_READ")
                .antMatchers(HttpMethod.POST, "/services/billing/**").hasAuthority("BILLING_WRITE")
                .antMatchers(HttpMethod.PUT, "/services/billing/**").hasAuthority("BILLING_WRITE")
                .antMatchers(HttpMethod.PATCH, "/services/billing/**").hasAuthority("BILLING_WRITE")
                .antMatchers(HttpMethod.DELETE, "/services/billing/**").hasAuthority("BILLING_WRITE")

                .antMatchers(HttpMethod.GET, "/services/sib/**").hasAuthority("SIB_READ")
                .antMatchers(HttpMethod.POST, "/services/sib/**").hasAuthority("SIB_WRITE")
                .antMatchers(HttpMethod.PUT, "/services/sib/**").hasAuthority("SIB_WRITE")
                .antMatchers(HttpMethod.PATCH, "/services/sib/**").hasAuthority("SIB_WRITE")
                .antMatchers(HttpMethod.DELETE, "/services/sib/**").hasAuthority("SIB_WRITE")

				.antMatchers("/services/oauth-server/**", "/eureka/**", "/services/access-control/user/regenerateConfirmation/**", "/services/access-control/user/registrationConfirm/**").permitAll()

                .anyRequest().authenticated();
		// @formatter:on
	}
}
