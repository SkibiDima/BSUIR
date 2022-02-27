package com.StringInvertor;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class StringInvertorController {

    @GetMapping("/invertor")
    public StringInvertor Invertor(@RequestParam(value = "req_string", defaultValue = "") String req_string) {

        String inverted_string = new StringBuilder(req_string).reverse().toString();

        return new StringInvertor(inverted_string);
    }
}
