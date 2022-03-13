package com.strinv;

import com.strinv.domain.StringInversion;
import com.strinv.services.StringInversionService;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

import static org.junit.jupiter.api.Assertions.assertEquals;

@SpringBootTest
class StringInversionApplicationTests {

    @Test
    void contextLoads() {
    }

    @Test
    void ServiceTest(){
        String testString = "Test string";
        StringInversion testObject1 = new StringInversion(testString);
        StringInversion testObject2 = new StringInversionService().inversion(testString);
        assertEquals(testObject1, testObject2);
    }
}
