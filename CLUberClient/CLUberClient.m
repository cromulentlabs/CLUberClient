//
//  CLUberClient.m
//  CLUberClient
//
// Copyright [2015] [Cromulent Labs, Inc.]
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "CLUberClient.h"

static NSString const* kUberBaseURL = @"https://api.uber.com";
static NSString *kUberBaseChinaURL = @"https://api.uber.com.cn";
static NSString const* kProductURL = @"/v1/products";
static NSString const* kTimeEstimateURL = @"/v1/estimates/time";

@implementation CLUberClient

- (void)productListForLatitude:(double)latitude longitude:(double)longitude
				 responseBlock:(void (^)(BOOL success, NSDictionary *response, NSError *error))responseBlock {
	NSString *callURL = [NSString stringWithFormat:@"%@%@", kUberBaseURL, kProductURL];
	NSString *parameters = [NSString stringWithFormat:@"latitude=%f&longitude=%f", latitude, longitude];
	[self callAPI:callURL params:parameters responseBlock:^(BOOL success, id response, NSError *error) {
		 if (responseBlock) {
			 responseBlock(success, response, error);
		 }
	 }];
}

- (void)timeEstimateForLatitude:(double)latitude longitude:(double)longitude
				  responseBlock:(void (^)(BOOL success, NSDictionary *response, NSError *error))responseBlock {
	NSString *callURL = [NSString stringWithFormat:@"%@%@", kUberBaseURL, kTimeEstimateURL];
	NSString *parameters = [NSString stringWithFormat:@"start_latitude=%f&start_longitude=%f", latitude, longitude];
	[self callAPI:callURL params:parameters responseBlock:^(BOOL success, id response, NSError *error) {
		 if (responseBlock) {
			 responseBlock(success, response, error);
		 }
	 }];
}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
			  task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
		newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest * __nullable))completionHandler {
	// Make sure original URL parameters are in the new request if they aren't properly added
	// to the location field already, which they should, but so far not so much...
	NSString *locationField = [response.allHeaderFields objectForKey:@"Location"];
	NSString *newUrlStr;
	if ([locationField containsString:@"?"]) {
		newUrlStr = locationField;
	}
	else {
		newUrlStr = [NSString stringWithFormat:@"%@?%@", locationField, response.URL.query];
	}
	NSMutableURLRequest *myNewRequest = [self requestForURLString:newUrlStr];
	completionHandler(myNewRequest);
}

#pragma mark - private

- (void) callAPI:(NSString *)apiUrl
		  params:(NSString *)parameters
   responseBlock:(void (^)(BOOL success, NSDictionary *response, NSError *error))responseBlock {
	NSString *requestUrl = [NSString stringWithFormat:@"%@?%@", apiUrl, parameters];
	NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
	NSMutableURLRequest *request = [self requestForURLString:requestUrl];
	NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request
												completionHandler:^(NSData *data,
																	NSURLResponse *response,
																	NSError *error) {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
		if (error) {
			if (responseBlock) {
				responseBlock(NO, nil, error);
			}
		}
		else if (httpResponse.statusCode != 200) {
			if (responseBlock) {
				NSError *error1 = [NSError errorWithDomain:NSURLErrorDomain code:httpResponse.statusCode userInfo:nil];
				responseBlock(NO, nil, error1);
			}
		}
		else {
			NSError *errorJSON;
			NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&errorJSON];
			if (responseBlock) {
				responseBlock(YES, responseDict, errorJSON);
			}
		}
	}];
	[dataTask resume];
}

- (NSMutableURLRequest *)requestForURLString:(NSString *)urlStr {
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30];
	[request setValue:[NSString stringWithFormat:@"Token %@", [self serverTokenForURL:urlStr]] forHTTPHeaderField:@"Authorization"];
	NSString *locale = [self currentLocale];
	[request setValue:locale forHTTPHeaderField:@"Accept-Language"];
	return request;
}

- (NSString *)currentLocale {
	NSString *locale = [NSLocale currentLocale].localeIdentifier;
	// iOS locales distinguish between simplified and traditional Chinese, but Uber doesn't so strip that out.
	locale = [locale stringByReplacingOccurrencesOfString:@"-Hans" withString:@""];
	locale = [locale stringByReplacingOccurrencesOfString:@"-Hant" withString:@""];
	return locale;
}

- (NSString *)serverTokenForURL:(NSString *)url {
	if ([url containsString:kUberBaseChinaURL]) {
		return self.chinaServerToken;
	}
	return self.serverToken;
}

@end
