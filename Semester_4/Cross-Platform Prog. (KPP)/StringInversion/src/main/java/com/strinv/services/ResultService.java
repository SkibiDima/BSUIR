package com.strinv.services;

import com.strinv.domain.Results;
import org.springframework.stereotype.Service;

@Service
public class ResultService {

    public Results inversion(String string){ return new Results(string);}
}
