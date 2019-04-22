/**
 * Created by Yevhenii on 22.04.2019.
 */

@IsTest
private class SurveyMailingServiceExecuterTest {
	@IsTest
	static void executeTest() {
		String jobId = System.schedule('Test SurveyMailingService Job', '0 0 8 13 2 ?', new SurveyMailingServiceExecuter());
		System.assert(String.isNotBlank(jobId));
	}
}