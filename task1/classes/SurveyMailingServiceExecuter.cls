/**
 * Created by Yevhenii on 21.04.2019.
 */

public with sharing class SurveyMailingServiceExecuter implements Schedulable {
	public void execute(SchedulableContext sc) {
		Database.executeBatch(new SurveyMailingService(), 100);
	}
}