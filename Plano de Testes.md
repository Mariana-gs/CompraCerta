# Plano de Testes – CompraCerta 

## 1. Caso de Uso: Gerenciar Itens na Lista
*Descrição: Abrange as funcionalidades de adicionar, editar e remover itens da lista de compras, conforme os requisitos funcionais 1 e 2.*

---

### **TC-01.1: Adicionar um novo item com sucesso**
- **ID:** `UC01-TC01`
- **Objetivo:** Verificar se o usuário consegue adicionar um novo item válido à lista de compras.
- **Pré-condições:** O aplicativo está aberto na tela da lista de compras.
- **Passos:**
  1. Clicar no botão para adicionar um novo item.
  2. No campo "Nome do item", inserir "Leite Integral".
  3. Confirmar a adição.
- **Resultado Esperado:** O item "Leite Integral" deve aparecer na lista de compras.
- **Resultado da Execução:** ✅ **Aprovado**

### **TC-01.2: Editar o nome de um item existente**
- **ID:** `UC01-TC02`
- **Objetivo:** Garantir que o usuário possa editar as informações de um item já existente na lista.
- **Pré-condições:** A lista de compras contém o item "Leite Integral".
- **Passos:**
  1. Selecionar o item "Leite Integral".
  2. Escolher a opção de edição.
  3. Alterar o nome do item para "Leite Desnatado".
  4. Salvar a alteração.
- **Resultado Esperado:** O nome do item na lista deve ser atualizado para "Leite Desnatado".
- **Resultado da Execução:** ❌ **Falha / Bloqueado**
  > **Observação:** O aplicativo ainda não possui a funcionalidade de edição implementada.

### **TC-01.3: Remover um item da lista**
- **ID:** `UC01-TC03`
- **Objetivo:** Verificar se um item pode ser removido permanentemente da lista de compras.
- **Pré-condições:** A lista de compras contém o item "Leite Desnatado".
- **Passos:**
  1. Selecionar o item "Leite Desnatado".
  2. Acionar a função de remoção (ex: deslizar o item ou clicar em um ícone de lixeira).
  3. Confirmar a exclusão na janela de diálogo, se houver.
- **Resultado Esperado:** O item "Leite Desnatado" deve ser removido da lista e o total da compra deve ser recalculado.
- **Resultado da Execução:** ✅ **Aprovado**

## 2. Caso de Uso: Definir Detalhes do Item
*Descrição: Refere-se à capacidade de definir quantidade e preço dos itens, conforme o requisito funcional 3.*

---

### **TC-02.1: Definir quantidade e preço de um item**
- **ID:** `UC02-TC01`
- **Objetivo:** Validar o cálculo do subtotal de um item após a inserção de quantidade e preço.
- **Pré-condições:** Um item "Pão de Forma" foi adicionado à lista.
- **Passos:**
  1. Editar o item "Pão de Forma".
  2. No campo "Quantidade", inserir `2`.
  3. No campo "Preço", inserir `8.50`.
  4. Salvar.
- **Resultado Esperado:** O item "Pão de Forma" deve exibir a quantidade e o preço. O total da lista de compras deve ser atualizado para R$ 17,00.
- **Resultado da Execução:** ✅ **Aprovado**

### **TC-02.2: Tentar inserir dados inválidos (não numéricos)**
- **ID:** `UC02-TC02`
- **Objetivo:** Verificar a robustez do sistema ao receber entradas inválidas nos campos de preço e quantidade.
- **Pré-condições:** A tela de edição de um item está aberta.
- **Passos:**
  1. No campo "Quantidade", tentar inserir o texto "dez".
  2. No campo "Preço", tentar inserir "caro".
- **Resultado Esperado:** O sistema deve impedir a inserção de caracteres não numéricos, exibir uma mensagem de erro ou desabilitar o botão de salvar, garantindo que o total da lista não seja afetado.
- **Resultado da Execução:** ✅ **Aprovado**

### **TC-02.3: Atualizar a quantidade de um item para zero**
- **ID:** `UC02-TC03`
- **Objetivo:** Garantir que o total da compra seja recalculado corretamente quando a quantidade de um item é zerada.
- **Pré-condições:** A lista contém um único item, "Café", com quantidade `1` e preço `15.00`. O total é R$ 15,00.
- **Passos:**
  1. Editar o item "Café".
  2. Alterar a quantidade para `0`.
  3. Salvar a alteração.
- **Resultado Esperado:** O item "Café" pode permanecer na lista com quantidade 0, mas o total da lista de compras deve ser atualizado para R$ 0,00.
- **Resultado da Execução:** ✅ **Aprovado**
  > **Observação:** O sistema impede adicionar itens de quantidade 0 no carrinho, cumprindo o objetivo de não afetar o valor total incorretamente.

## 3. Caso de Uso: Comparar Preços por Unidade
*Descrição: Testa a funcionalidade de comparação de preços por unidade de medida, conforme o requisito funcional 4.*

---

### **TC-03.1: Comparar preço por quilograma (Kg)**
- **ID:** `UC03-TC01`
- **Objetivo:** Verificar se o sistema calcula e exibe corretamente o preço por Kg para dois produtos diferentes.
- **Pré-condições:** Foram adicionados dois itens à lista:
    - Item A: Arroz 5kg, Preço: R$ 25,00.
    - Item B: Arroz 1kg, Preço: R$ 6,00.
- **Passos:**
  1. Acessar a tela de comparação de preços.
  2. Selecionar os dois itens para comparação.
  3. Definir a unidade como "Kg" para ambos.
- **Resultado Esperado:** O sistema deve calcular e exibir o valor por unidade: R$ 5,00/kg para o Item A e R$ 6,00/kg para o Item B, destacando o Item A como a opção mais econômica.
- **Resultado da Execução:** ✅ **Aprovado**

### **TC-03.2: Comparar preço por litro (L) e mililitro (ml)**
- **ID:** `UC03-TC02`
- **Objetivo:** Validar a comparação entre produtos com a mesma unidade de medida, mas volumes diferentes.
- **Pré-condições:** Foram adicionados dois itens à lista:
    - Item A: Refrigerante 2L, Preço: R$ 8,00.
    - Item B: Refrigerante 600ml, Preço: R$ 4,20.
- **Passos:**
  1. Acessar a tela de comparação.
  2. Selecionar os dois itens e definir suas respectivas unidades e volumes (2L para A, 0.6L para B).
- **Resultado Esperado:** O sistema deve normalizar e exibir o preço por litro: R$ 4,00/L para o Item A e R$ 7,00/L para o Item B, indicando o Item A como mais vantajoso.
- **Resultado da Execução:** ✅ **Aprovado**

### **TC-03.3: Tentativa de comparar itens com unidades incompatíveis**
- **ID:** `UC03-TC03`
- **Objetivo:** Verificar o comportamento do sistema ao tentar comparar produtos com unidades de medida incompatíveis.
- **Pré-condições:** A lista contém:
    - Item A: Arroz 1kg.
    - Item B: Leite 1L.
- **Passos:**
  1. Acessar a tela de comparação.
  2. Tentar selecionar o Item A (Kg) e o Item B (L) para comparação.
- **Resultado Esperado:** O sistema não deve permitir a comparação, exibindo uma mensagem informativa como "A comparação só é possível entre itens com a mesma unidade de medida (ex: Kg e g, L e ml)".
- **Resultado da Execução:** ✅ **Aprovado**

## 4. Caso de Uso: Gerenciar Orçamento
*Descrição: Cobre a definição de um orçamento e o alerta quando o total da compra o ultrapassa, conforme os requisitos 5 e 6.*

---

### **TC-04.1: Definir um valor de orçamento**
- **ID:** `UC04-TC01`
- **Objetivo:** Garantir que o usuário possa definir com sucesso um orçamento máximo para as compras.
- **Pré-condições:** N/A.
- **Passos:**
  1. Navegar até a funcionalidade de orçamento.
  2. Inserir `150.00` no campo de orçamento máximo.
  3. Confirmar.
- **Resultado Esperado:** A interface deve exibir de forma clara que o orçamento definido é de R$ 150,00.
- **Resultado da Execução:** ✅ **Aprovado**

### **TC-04.2: Exibir alerta ao exceder o orçamento**
- **ID:** `UC04-TC02`
- **Objetivo:** Verificar se um alerta visual é acionado quando o valor total da lista ultrapassa o orçamento.
- **Pré-condições:** O orçamento está definido em R$ 150,00. O total atual da lista de compras é R$ 140,00.
- **Passos:**
  1. Adicionar um novo item à lista com preço de R$ 15,00.
- **Resultado Esperado:** O total da lista será atualizado para R$ 155,00. O sistema deve exibir um alerta visual claro (ex: cor do texto do total em vermelho, um ícone de aviso) para indicar que o orçamento foi excedido.
- **Resultado da Execução:** ✅ **Aprovado**

### **TC-04.3: Total da lista igual ao orçamento**
- **ID:** `UC04-TC03`
- **Objetivo:** Testar o comportamento do sistema no limite exato do orçamento.
- **Pré-condições:** O orçamento está definido em R$ 150,00. O total atual da lista é R$ 130,00.
- **Passos:**
  1. Adicionar um novo item de R$ 20,00 à lista.
- **Resultado Esperado:** O total da lista será R$ 150,00. Nenhum alerta de "orçamento excedido" deve ser exibido. O sistema pode, opcionalmente, mudar a cor do total para amarelo para indicar que o limite foi atingido.
- **Resultado da Execução:** ❌ **Falha**
  > **Observação:** Comportamento incorreto. O sistema já exibe o alerta vermelho (excedido) quando o valor apenas se aproxima do orçamento, antes de atingi-lo ou ultrapassá-lo.

## 5. Caso de Uso: Adicionar Itens ao Carrinho
*Descrição: Verifica a funcionalidade de marcar itens como "já comprados", conforme o requisito funcional 7.*

---

### **TC-05.1: Mover um item para o carrinho**
- **ID:** `UC05-TC01`
- **Objetivo:** Verificar se um item da lista pode ser marcado como "comprado" (movido para o carrinho).
- **Pré-condições:** A lista contém o item "Shampoo" que custa R$ 22,00.
- **Passos:**
  1. Localizar o item "Shampoo" na lista.
  2. Marcar o checkbox ou acionar a opção "Adicionar ao carrinho".
- **Resultado Esperado:** O item "Shampoo" deve ser marcado visualmente como "no carrinho" (ex: texto riscado ou cor de fundo diferente). O cálculo do valor total da lista não deve ser alterado.
- **Resultado da Execução:** ✅ **Aprovado**

### **TC-05.2: Retirar um item do carrinho**
- **ID:** `UC05-TC02`
- **Objetivo:** Garantir que um item marcado como "comprado" possa ser revertido para o estado "a comprar".
- **Pré-condições:** O item "Shampoo" foi previamente movido para o carrinho.
- **Passos:**
  1. Localizar o item "Shampoo" na lista.
  2. Desmarcar o checkbox ou acionar a opção "Remover do carrinho".
- **Resultado Esperado:** A marcação visual de "no carrinho" deve ser removida do item, retornando-o ao seu estado padrão.
- **Resultado da Execução:** ✅ **Aprovado**

### **TC-05.3: Comportamento do totalizador com itens no carrinho**
- **ID:** `UC05-TC03`
- **Objetivo:** Verificar se os totalizadores (total geral, total no carrinho, total a comprar) funcionam corretamente.
- **Pré-condições:** A lista contém:
    - Item A: Sabonete, R$ 5,00.
    - Item B: Creme Dental, R$ 7,00.
- **Passos:**
  1. Mover o "Sabonete" para o carrinho.
- **Resultado Esperado:** O sistema deve exibir:
    - Total Geral: R$ 12,00.
    - Total no Carrinho: R$ 5,00.
    - Total a Comprar: R$ 7,00.
- **Resultado da Execução:** ✅ **Aprovado**