package org.example.moon;

import org.junit.Test;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

public class TestDemo {


    /**
     * 链表反转
     * @param args
     */
    public static void main(String[] args) {
        NodeList head = new NodeList(1);
        head.next = new NodeList(2);
        head.next.next = new NodeList(3);
        head.next.next.next = new NodeList(4);
        head.next.next.next.next = new NodeList(5);
        printList(head);
        NodeList reverse = reverse(head);
        printList(reverse);

    }

    public static void printList(NodeList head) {
        NodeList curt = head;
        while (curt != null) {
            System.out.println(curt.var);
            if (curt.next != null) {
                System.out.println("->");
            }
            curt = curt.next;
        }

    }

    static class NodeList {
        int var;
        NodeList next;

        public NodeList(int var) {
            this.var = var;
        }
    }

    static NodeList reverse(NodeList head) {
        NodeList pre = null;
        NodeList curt = head;
        while (curt != null) {
            NodeList nextTemp = curt.next;
            curt.next = pre;
            pre = curt;
            curt = nextTemp;
        }
        return pre;
    }
@Test
public void test11111(){
    int[] numbers=new int[]{5,6,8,9};
    int target=17;
    System.out.println(Arrays.toString(twoNumberSun(numbers, target)));
}
    /**
     * 两数之和
     * @param numbers
     *
     */
    public  int[] twoNumberSun(int[] numbers,int target) {
        //key值,value就是下标
        Map<Integer, Integer> hashMap = new HashMap<>();
        for (int i = 0; i < numbers.length; i++) {
            int i1 = target - numbers[i];
            if (hashMap.containsKey(i1)) {
                return new int[]{i, hashMap.get(i1)};
            } else {
                hashMap.put(numbers[i], i);

            }
        }
        throw new RuntimeException("没有找到二数之和的下标值");
    }

}
