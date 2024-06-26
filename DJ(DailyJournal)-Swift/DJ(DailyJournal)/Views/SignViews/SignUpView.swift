//
//  SignUpView.swift
//  DJ(DailyJournal)
//
//  Created by 김수영 on 6/8/24.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var signViewModel: SignViewModel
    @Environment(\.dismiss) var dismiss
    @State private var showAlert = false
    @State private var responseMessage = ""
    @State private var navigateToSignIn = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack {
                    Text("회원가입")
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(Color.ivory)
                        
                    Spacer()
                    
                    TextField(text: $signViewModel.userNickName) {
                        Text("사용자 이름")
                            .foregroundStyle(.gray)
                    }
                    .padding(.vertical)
                    .padding(.leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .foregroundStyle(Color.ivory)
                    
                    TextField(text: $signViewModel.userID) {
                        Text("아이디")
                            .foregroundStyle(.gray)
                    }
                    .padding(.vertical)
                    .padding(.leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .foregroundStyle(Color.ivory)
                    
                    SecureField(text: $signViewModel.password) {
                        Text("비밀번호")
                            .foregroundStyle(.gray)
                    }
                    .padding(.vertical)
                    .padding(.leading)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .foregroundStyle(Color.ivory)
                    
                    Button(action: {
                        signViewModel.signUp { signUpResponse in
                            if signUpResponse.success {
                                responseMessage = "회원가입에 성공하였습니다. 로그인해주세요."
                                showAlert = true
                                navigateToSignIn = true
                            } else {
                                responseMessage = "회원가입에 실패하였습니다. \(signUpResponse.message)"
                                showAlert = true
                            }
                        }
                    }, label: {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical)
                    })
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.ivory, lineWidth: 1)
                    )
                    .padding(.horizontal)
                    .foregroundStyle(Color.ivory)
                    
                    //서비스 이용약관이랑 개인정보 정책을 작성한 Url필요! 누르면 넘어가도록 해야함!
                    Text("가입 시, DJ의 다음 사항에 동의하는 것으로 간주합니다. 서비스 이용약관 및 개인정보 정책")
                        .padding()
                        .foregroundStyle(Color.gray)
                        .font(.subheadline)
                    
                    Spacer()
                }
                .padding()
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("회원가입 결과"), message: Text(responseMessage), dismissButton: .default(Text("확인"), action: {
                    if navigateToSignIn {
                        dismiss()
                    }
                }))
            }
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(SignViewModel())
}
