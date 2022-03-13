package com.strinv.controllers;

import com.strinv.domain.Results;
import com.strinv.domain.StringInversion;
import com.strinv.services.ResultService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class StringInversionController {
    private ResultService resultService;

    @GetMapping("/inversion")
    public Results Inversion(@RequestParam(value = "req_string", defaultValue = "Epam") String req_string){
       //return resultService.inversion(req_string);
        return new Results(req_string);
    }

}
