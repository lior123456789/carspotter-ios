import SwiftUI

// MARK: - Model

struct ChatMsg: Identifiable, Equatable {
    let id = UUID()
    let role: String   // "user" | "assistant"
    let text: String
}

// MARK: - Service

@MainActor
final class AskService: ObservableObject {
    func ask(car: CarInfo, history: [ChatMsg]) async throws -> String {
        let carDict: [String: Any] = [
            "year": car.year, "make": car.make, "model": car.model,
            "msrp": car.msrp, "valueRange": car.valueRange,
            "engine": car.engine, "horsepower": car.horsepower,
            "category": car.category, "rarity": car.rarity,
        ]
        let msgs = history.map { ["role": $0.role, "content": $0.text] }
        var req = URLRequest(url: API.url(.ask))
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONSerialization.data(withJSONObject: ["car": carDict, "messages": msgs])

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "Ask", code: (resp as? HTTPURLResponse)?.statusCode ?? 0,
                          userInfo: [NSLocalizedDescriptionKey: "AI is busy — try again."])
        }
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        guard let answer = json?["answer"] as? String else {
            throw NSError(domain: "Ask", code: 0, userInfo: [NSLocalizedDescriptionKey: "No answer."])
        }
        return answer
    }
}

// MARK: - View

struct AskAIView: View {
    let car: CarInfo
    @Environment(\.dismiss) private var dismiss
    @StateObject private var service = AskService()
    @State private var messages: [ChatMsg] = []
    @State private var input = ""
    @State private var isLoading = false

    private let starters = [
        "Is it a good investment?",
        "What's it like to drive?",
        "Why is it rare?",
        "Common problems to watch for?",
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spotterInk.ignoresSafeArea()
                VStack(spacing: 0) {
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(alignment: .leading, spacing: 14) {
                                intro
                                ForEach(messages) { m in bubble(m) }
                                if isLoading { typing }
                                Color.clear.frame(height: 1).id("bottom")
                            }
                            .padding(16)
                        }
                        .onChange(of: messages.count) { _, _ in
                            withAnimation { proxy.scrollTo("bottom", anchor: .bottom) }
                        }
                    }
                    inputBar
                }
            }
            .navigationTitle("Ask about this \(car.model)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Done") { dismiss() }.foregroundStyle(Color.spotterMute)
                }
            }
        }
    }

    private var intro: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Ask me anything about the \(car.year) \(car.make) \(car.model) — specs, value, history, what to watch for.")
                .font(.system(size: 14, design: .rounded))
                .foregroundStyle(Color.spotterMute)
            if messages.isEmpty {
                FlowChips(items: starters) { send($0) }
            }
        }
    }

    private func bubble(_ m: ChatMsg) -> some View {
        HStack {
            if m.role == "user" { Spacer(minLength: 40) }
            Text(m.text)
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(m.role == "user" ? Color.spotterInk : .white)
                .padding(.horizontal, 14).padding(.vertical, 10)
                .background(
                    m.role == "user"
                        ? AnyShapeStyle(LinearGradient.spotterBrand)
                        : AnyShapeStyle(Color.spotterPanel)
                )
                .overlay(RoundedRectangle(cornerRadius: 16)
                    .stroke(m.role == "user" ? .clear : Color.spotterLine))
                .clipShape(RoundedRectangle(cornerRadius: 16))
            if m.role == "assistant" { Spacer(minLength: 40) }
        }
    }

    private var typing: some View {
        HStack {
            Text("…")
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(Color.spotterMute)
                .padding(.horizontal, 16).padding(.vertical, 6)
                .background(Color.spotterPanel)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            Spacer()
        }
    }

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("", text: $input, prompt: Text("Ask a question…").foregroundColor(.spotterMute))
                .font(.system(size: 15, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 14).padding(.vertical, 11)
                .background(Color.spotterPanel)
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(Color.spotterLine))
                .clipShape(RoundedRectangle(cornerRadius: 22))
                .onSubmit { send(input) }
            Button {
                send(input)
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(input.trimmingCharacters(in: .whitespaces).isEmpty || isLoading
                                     ? AnyShapeStyle(Color.spotterMute) : AnyShapeStyle(LinearGradient.spotterBrand))
            }
            .disabled(input.trimmingCharacters(in: .whitespaces).isEmpty || isLoading)
        }
        .padding(12)
        .background(Color.spotterInk)
        .overlay(Rectangle().fill(Color.spotterLine).frame(height: 1), alignment: .top)
    }

    private func send(_ text: String) {
        let q = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty, !isLoading else { return }
        input = ""
        messages.append(ChatMsg(role: "user", text: q))
        isLoading = true
        Task {
            do {
                let answer = try await service.ask(car: car, history: messages)
                messages.append(ChatMsg(role: "assistant", text: answer))
            } catch {
                messages.append(ChatMsg(role: "assistant", text: error.localizedDescription))
            }
            isLoading = false
        }
    }
}

/// Simple wrapping row of tappable suggestion chips.
private struct FlowChips: View {
    let items: [String]
    let onTap: (String) -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                Button { onTap(item) } label: {
                    Text(item)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.spotterCyan)
                        .padding(.horizontal, 14).padding(.vertical, 9)
                        .background(Color.spotterCyan.opacity(0.08))
                        .overlay(Capsule().stroke(Color.spotterCyan.opacity(0.3)))
                        .clipShape(Capsule())
                }
            }
        }
    }
}
