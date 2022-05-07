package com.strinv.stats;

import org.springframework.stereotype.Component;

@Component
public class Stats {

    public int totalRequests = 0;
    public int wrongRequests = 0;

    public String min;
    public String max;

    public String mostCommon;
}
