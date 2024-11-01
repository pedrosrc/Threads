require 'gruff'
require 'csv'
require 'securerandom'

def bubble_sort(arr)
  n = arr.length
  loop do
    swapped = false
    (n - 1).times do |i|
      if arr[i] > arr[i + 1]
        arr[i], arr[i + 1] = arr[i + 1], arr[i]
        swapped = true
      end
    end
    break unless swapped
  end
  arr
end

def quick_sort(arr)
  return arr if arr.length <= 1 
  pivot = arr.delete_at(rand(arr.length))
  left, right = arr.partition { |element| element <= pivot }
  quick_sort(left) + [pivot] + quick_sort(right)
end

def insertion_sort(arr)
  (1...arr.length).each do |i|
    key = arr[i]
    j = i - 1
    while j >= 0 && arr[j] > key
      arr[j + 1] = arr[j]
      j -= 1
    end
    arr[j + 1] = key 
  end
  arr
end

tamanhos = [10000, 20000, 30000, 40000, 50000, 60000, 70000, 80000, 90000, 100000]
tempos_execucao = {
  bubble_sort: [],
  quick_sort: [],
  insertion_sort: []
}

threads = []

tamanhos.each do |tamanho|
  array = Array.new(tamanho) { rand(1..10_000) }

  [:quick_sort, :bubble_sort, :insertion_sort].each do |metodo|
    threads << Thread.new do
      inicio = Time.now
      send(metodo, array.dup) 
      fim = Time.now
      tempos_execucao[metodo] << fim - inicio
    end
  end
end

threads.each(&:join)

# Salvar resultados em um arquivo CSV
CSV.open("tempos_execucao_algoritmos.csv", "wb") do |csv|
  csv << ["Tamanho do Array", "Bubble Sort (s)", "Quick Sort (s)", "Insertion Sort (s)"]
  
  tamanhos.each_with_index do |tamanho, idx|
    csv << [tamanho, tempos_execucao[:bubble_sort][idx], tempos_execucao[:quick_sort][idx], tempos_execucao[:insertion_sort][idx]]
  end
end

# Criar gráfico para exibir tempos de execução
g = Gruff::Line.new
g.title = 'Comparação de Algoritmos de Ordenação com Diferentes Tamanhos de Array'
g.x_axis_label = 'Tamanho do Array'
g.y_axis_label = 'Tempo de Execução (s)'

g.labels = tamanhos.each_with_index.map { |tamanho, idx| [idx, tamanho.to_s] }.to_h

tempos_execucao.each do |funcao, tempos|
  g.data funcao.to_s, tempos
end

g.colors = ['blue', 'green', 'red']
g.marker_font_size = 12

g.write('comparacao_algoritmos_por_tamanho.png')
