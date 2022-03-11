package test;

import java.text.DecimalFormat;

public class JustTest {

	public static void main(String[] args) {
		int a = 100;
		int b = 2342;
		DecimalFormat df = new DecimalFormat("0.000000");//设置保留位数
		
		System.out.println(df.format((float)a/b));
	}
}
