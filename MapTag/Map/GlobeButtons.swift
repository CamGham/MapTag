//
//  GlobaButtons.swift
//  MapTag
//
//  Created by Cam Graham on 20/04/2024.
//

import SwiftUI

struct GlobeButtons: View {
    @Binding var openProfileSheet: Bool
    @State var search = false
    @State var searchQuery = ""
    
    private func showProfile() {
        openProfileSheet.toggle()
    }
    @Namespace var searchBar
    @FocusState var searchBarIsFocused: Bool
    
    var body: some View {
        HStack {
            Spacer()
            VStack {
                if !search {
                    HStack {
                        Button(action: showProfile, label: {
                            Image(systemName: "person.crop.circle")
                        })
                        .buttonStyle(BorderedProminentButtonStyle())
                        .padding(4)
                        
                        
                        Button(action: {
                            
                            withAnimation {
                                search.toggle()
                            }
                            
                        }, label: {
                            Image(systemName: "magnifyingglass")
                                .matchedGeometryEffect(id: "icon", in: searchBar, isSource: true)
//                            Label("Search...", systemImage: "magnifyingglass")
//                                .matchedGeometryEffect(id: "icon", in: searchBar, isSource: true)
//                            HStack {
//                                
//                                Image(systemName: "magnifyingglass")
//                                    .matchedGeometryEffect(id: "icon", in: searchBar, isSource: true)
//                                Text("Search")
//                            }
                        })
                        .foregroundStyle(.white)
                        .buttonStyle(BorderedButtonStyle())
                        .matchedGeometryEffect(id: "searchbar", in: searchBar, isSource: true)
                        .padding(4)
                        
                        
                        Spacer()
                        
                    }
                    .padding()
                }
                else {
//                    GeometryReader(content: { geo in
                    
                        VStack {
                            HStack {
//                                Button(action: showProfile, label: {
//                                    Image(systemName: "person.crop.circle")
//                                })
//                                .buttonStyle(BorderedProminentButtonStyle())
//                                .padding(4)
                                ZStack {
//                                    HStack {
////                                        Image(systemName: "magnifyingglass")
//                                            .matchedGeometryEffect(id: "icon", in: searchBar, isSource: false)
//                                            .padding(2)
//                                        Spacer()
//                                    }
//                                    .padding(.vertical, 7)
//                                    .background(Color(.tertiarySystemGroupedBackground))
                                    
                                    HStack {
                                        Image(systemName: "magnifyingglass")
                                            .matchedGeometryEffect(id: "icon", in: searchBar, isSource: false)
                                            .foregroundStyle(Color(.tertiaryLabel))
                                        
                                        TextField(text: $searchQuery, prompt: Text("Search Countries...")){}
                                            .focused($searchBarIsFocused)
                                            .onAppear(perform: {
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                                    searchBarIsFocused.toggle()
                                                }
                                            })
                                            .textFieldStyle(.plain)
                                            .background(Color(.tertiarySystemGroupedBackground))
                                            .matchedGeometryEffect(id: "searchbar", in: searchBar, isSource: false)
                                            .submitLabel(.done)
                                            .overlay(alignment: .trailing) {
                                                if searchQuery != "" {
                                                    Button(action: {
                                                        searchQuery = ""
                                                    }, label: {
                                                        Image(systemName: "xmark.circle.fill")
                                                            .foregroundStyle(Color(.systemGray))
                                                    })
                                                }
                                            }
                                    }
                                    .padding(4)
                                    .background(Color(.tertiarySystemGroupedBackground))
                                    .clipShape(.rect(cornerRadius: 8))
                                }
                            
                                Button("Close") {
                                    withAnimation {
                                        search.toggle()
                                    }
                                    
                                }
                            }
                            
                            
                            CountryListView(searchQuery: searchQuery)
                                                        
                            
                        }
                        .padding()
                        .background(Color(.secondarySystemGroupedBackground), in: .rect(cornerRadius: 20))
//                        .background(Color(.secondarySystemBackground), in: .rect(cornerRadius: 20))
                    
//                        .background(.black.opacity(0.2), in: .rect(cornerRadius: 20))
                    
//                        .background(Color(.systemGroupedBackground))
//                        .background(.thinMaterial, in: .rect(cornerRadius: 8))
                        
                        
                        
//                        .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.8)
//                        .clipShape(.rect(cornerRadius: 20.0))
//                        .position(CGPoint(x: geo.frame(in: .local).midX, y: geo.frame(in: .local).midY))
//                        .background(.black.opacity(0.4))
//                    })
                }
                

                
                Spacer()
            }
            Spacer()
        }
        
    }
}

#Preview {
    ZStack {
        Color.black.opacity(0.2)
            .ignoresSafeArea()
        GlobeButtons(openProfileSheet: .constant(false))
    }
}
