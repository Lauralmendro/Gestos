//
//  ContentView.swift
//  Gestos
//
//  Created by Santiago Pavón Gómez on 07/12/2019.
//  Copyright © 2019 IWEB. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Modificdores")) {
                    NavigationLink(destination: TapView()) {
                        Text("Double onTap")
                    }
                    NavigationLink(destination: FullTapView()) {
                        Text("onTap Responde en toda la pantalla")
                    }
                }
                Section(header: Text("Gestos")) {
                    NavigationLink(destination: GestoTapView()) {
                        Text("Gesto Tap")
                    }
                    NavigationLink(destination: GestoLongPressView()) {
                        Text("Gesto LongPress")
                    }
                    NavigationLink(destination: GestoDragView()) {
                        Text("Gesto Drag")
                    }
                    NavigationLink(destination: GestoDrag0View()) {
                        Text("Pinta Drag")
                    }
                    NavigationLink(destination: GestoMagnificationView()) {
                        Text("Gesto Magnification")
                    }
                    NavigationLink(destination: MagGSView()) {
                        Text("Magn. con @GestureState")
                    }
                    NavigationLink(destination: GestoRotationView()) {
                        Text("Gesto Rotation")
                    }
                    NavigationLink(destination: SimultaneoView()) {
                        Text("Gestos Magnificar y Rotar")
                    }
                }
                Section(header: Text("Examen")) {
                    NavigationLink(destination: PiramideView()) {
                        Text("Pirámide")
                    }
                }
            }
            .navigationBarTitle(Text("Gestos"))
        }
    }
}

// Modificador onTapGesture
struct TapView: View {
    @State var size: CGFloat = 200
    
    var body: some View {
        Image("dharma")
            .resizable()
            .frame(width: size, height: size)
            .scaledToFill()
            .clipped()
            .onTapGesture(count: 2) {
                self.size = 300 - self.size
        }
        .navigationBarTitle(Text("Doble Tap"))
    }
}

// Usar .contentShape(Rectangle()) para que el gesto se
// reconozca en toda la superficie del VStack.
// Sin usarlo solo se reconoce encima de las subviews.
struct FullTapView: View {
    @State var size: CGFloat = 200
    
    var body: some View {
        GeometryReader {geometry in
            
            VStack {
                Spacer()
                Image("dharma")
                    .resizable()
                    .frame(width: self.size, height: self.size)
                    .scaledToFill()
                    .clipped()
                Spacer()
                
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.yellow)
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                self.size = 300 - self.size
            }
        }
        .navigationBarTitle(Text("Full Area Tap"))
    }
}

// Usar gesto TapGesture
struct GestoTapView: View {
    @State var size: CGFloat = 200
    
    var body: some View {
        Image("dharma")
            .resizable()
            .frame(width: size, height: size)
            .scaledToFill()
            .clipped()
            .gesture(
                TapGesture(count: 2)
                    .onEnded {
                        self.size = 300 - self.size
            })
            .navigationBarTitle(Text("Gesto: Doble Tap"))
    }
}

// Usar gesto LongPressGesture.
// Tambien hay un modificador para hacer lo mismo.
struct GestoLongPressView: View {
    @State var size: CGFloat = 200
    
    var body: some View {
        Image("dharma")
            .resizable()
            .frame(width: size, height: size)
            .scaledToFill()
            .clipped()
            .gesture(
                LongPressGesture(minimumDuration: 1, maximumDistance: 20)
                .onEnded { _ in
                    self.size = 300 - self.size
            })
            .navigationBarTitle(Text("Gest: Long Press"))
    }
}

// Gesto DragGesture para mover una imagen con .onChanged.
// Al final la pongo en la posicion inicial en .onEnded.
struct GestoDragView: View {
    @State var offset: CGSize = .zero
    
    var body: some View {
        Image("dharma")
            .resizable()
            .frame(width: 200, height: 200)
            .offset(offset)
            .scaledToFill()
            .gesture(
                DragGesture(minimumDistance: 1, coordinateSpace: .local)
                .onChanged { value in
                        self.offset = value.translation
                }
                .onEnded { _ in
                    self.offset = .zero
            })
            .navigationBarTitle(Text("Gest: Drag"))
    }
}


/*
 * Uso un gesto Drag con minimumDistance=0.
 * Uso este gesto porque con el puedo acceder a la
 * localizacion del evento para saber donde estoy.
 * Pinto una imgen en cada punto por el que paso.
 */
struct GestoDrag0View: View {
    
    @State var puntos: [Punto] = []
    
    struct Punto: Identifiable {
        let id: UUID = UUID()
        var position: CGPoint
    }
    
    var body: some View {
        GeometryReader {geometry in
            ZStack(alignment: .topLeading) {
                ForEach(self.puntos) { punto in
                    Image("ddmini")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .scaledToFill()
                        .position(punto.position)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.yellow)
            .contentShape(Rectangle())
            .clipped()
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let x = value.startLocation.x + value.translation.width
                        let y = value.startLocation.y + value.translation.height
                        let p = CGPoint(x: x, y: y)
                        self.puntos.append(Punto(position: p))
                }
            )
                .navigationBarTitle(Text("Pinta Drag"))
                .navigationBarItems(trailing: Button(action: {
                    self.puntos.removeAll()
                }) {
                    Image(systemName: "clear")
                })
        }
    }
}


// Gesto MagnificationGesture para escalar una imagen con .onChanged.
// Al final la dejo de tamaño inicial en .onEnded.
struct GestoMagnificationView: View {
    @State var scale: CGFloat = 1
    
    var body: some View {
        Image("dharma")
            .resizable()
            .frame(width: 300, height: 300)
            .scaledToFill()
            .scaleEffect(scale)
            .gesture(
                MagnificationGesture(minimumScaleDelta: 0.01)
                .onChanged { scale in
                        print("Scale:", scale)
                        self.scale = scale
                }
                .onEnded { _ in
                    self.scale = 1
            })
            .navigationBarTitle(Text("Gest: Magnification"))
    }
}

// Uso @GestureStare para que al final se restaure el estado inicial.
// No tengo que hacerlo en .onEnded.
struct MagGSView: View {
    @GestureState var scale: CGFloat = 1
    
    var body: some View {
        Image("dharma")
            .resizable()
            .frame(width: 300, height: 300)
            .scaledToFill()
            .scaleEffect(scale)
            .gesture(
                MagnificationGesture(minimumScaleDelta: 0.01)
                    .updating($scale) { (value, state, transaction) in
                        state = value
            })
            .navigationBarTitle(Text("Magn @GestureState"))
    }
}

// Gesto RotationGesture para rotar una imagen con .onChanged.
// Al final la dejo sin girar en .onEnded.
struct GestoRotationView: View {
    @State var angle: Angle = .zero
    
    var body: some View {
        Image("dharma")
            .resizable()
            .frame(width: 300, height: 300)
            .scaledToFill()
            .rotationEffect(angle)
            .gesture(
                RotationGesture(minimumAngleDelta: Angle(degrees: 1))
                .onChanged { angle in
                        print("Angle:", angle)
                        self.angle = angle
                }
                .onEnded { _ in
                    self.angle = .zero
            })
            .navigationBarTitle(Text("Gest: Rotation"))
    }
}

// Dos gestos simultaneos: Magnificar y Rotar
struct SimultaneoView: View {
    
    // Valor acumulado de escala de todos los gestos realizados
    @State var scaleTotal: CGFloat = 1
    
    // Escala del gesto actual
    @State var scale: CGFloat = 1
    
    // Valor acumulado de angulo de todos los gestos realizados
    @State var angleTotal: Angle = .zero
    
    // Angulo del gesto actual
    @State var angle: Angle = .zero

    var body: some View {
        Image("dharma")
            .resizable()
            .frame(width: 300, height: 300)
            .scaledToFill()
            .rotationEffect(angleTotal+angle)
            .scaleEffect(scaleTotal*scale)
            .gesture(
                MagnificationGesture(minimumScaleDelta: 0.01)
                .onChanged { scale in
                        self.scale = scale
                }
                .onEnded { _ in
                    self.scaleTotal *= self.scale
                    self.scale = 1
                }
                .simultaneously(with:
                    
                    RotationGesture(minimumAngleDelta: Angle(degrees: 1))
                    .onChanged { angle in
                            self.angle = angle
                    }
                    .onEnded { _ in
                        self.angleTotal += self.angle
                        self.angle = .zero
                    }
                )
        )
            .navigationBarTitle(Text("Magnificar y Rotar"))
    }
}


struct PiramideView: View {
    
    struct Piramide: Shape {
        
        var fAltura: CGFloat
        
        func path(in rect: CGRect) -> Path {
            
            let w = rect.size.width
            let h = rect.size.height
            
            var path = Path()

            path.move(to: CGPoint(x: 0, y: h))
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: w/2, y: h*(1-fAltura)))
            path.closeSubpath()
            
            return path
        }
    }
    
    @GestureState var scale: CGFloat = 1

    var body: some View {
        GeometryReader {geometry in
            Piramide(fAltura: self.scale)
                .fill(LinearGradient(
                    gradient: Gradient(colors: [.green, .red, .blue, .yellow]),
                    startPoint: UnitPoint(x: 0.5, y: 1-self.scale),
                    endPoint: .bottom))
                .overlay(Piramide(fAltura: self.scale)
                    .stroke(Color.red, lineWidth: 3))
                .frame(width: geometry.size.width,
                       height: geometry.size.height)
                .contentShape(Rectangle())
                .gesture(
                    MagnificationGesture(minimumScaleDelta: 0.01)
                        .updating(self.$scale) { (value, state, transaction) in
                            state = value
                })
        }
        .padding()
        .navigationBarTitle(Text("Pirámide"))

    }
}
 
  

        
 
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
