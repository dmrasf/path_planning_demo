#!/bin/python
import matplotlib.pyplot as plt
from PIL import Image, ImageFont, ImageDraw, ImageFont
import numpy as np
import json
import sys
import math
from enum import Enum


ContourOrder = Enum('ContourOrder', ('Counterclockwise', 'Clockwise'))


class Map:
    """构建地图方法类"""

    def __init__(self, data):
        """构建地图"""
        contents = dict()
        contents = json.loads(data)
        try:
            self.__type = contents['type']
        except Exception as _:
            print("地图格式错误")
            exit(0)
        if self.__type == 'custom map':
            try:
                self.__width = contents['width']
                self.__heigth = contents['heigth']
                self.__grid = contents['grid']
                self.__start_point = contents['start']
                self.__end_point = contents['end']
                self.__robot_size = contents['robotSize']
                self.__barriers = contents['barriers']
                self.__w_grid = math.ceil(self.__width/self.__grid)
                self.__h_grid = math.ceil(self.__heigth/self.__grid)
                self.__my_map = np.zeros(
                    (self.__h_grid, self.__w_grid), dtype='uint8')
                self.__my_map[self.__my_map == 0] = 255
                self.__draw_barriers()
                self.__fillHole()
                self.__needExpansionGrid = math.ceil(
                    (self.__robot_size-self.__grid)/2/self.__grid)
                if self.__needExpansionGrid < 0:
                    self.__needExpansionGrid = 0
                self.__expanded = self.__expand_map(self.__needExpansionGrid)
                self.__my_map[self.__expanded[0], self.__expanded[1]] = 0
            except Exception as _:
                print("地图格式错误")
                exit(0)
        elif self.__type == 'random map':
            try:
                self.__width_block = contents['widthBlock']
                self.__heigth_block = contents['heigthBlock']
                self.__blank_size = contents['blankSize']
                self.__border = contents['border']
                self.__start_point = contents['start']
                self.__end_point = contents['end']
                self.__wall_thickness = contents['wallThickness']
                self.__width = self.__border*2+self.__blank_size * \
                    self.__width_block + self.__wall_thickness * \
                    (self.__width_block-1)
                self.__heigth = self.__border*2+self.__blank_size * \
                    self.__heigth_block + self.__wall_thickness * \
                    (self.__heigth_block-1)
                self.__grid = contents['grid']
                self.__robot_size = contents['robotSize']
                self.__horizontall_wall = contents['horizontal']
                self.__vertical_wall = contents['vertical']
                self.__w_grid = math.ceil(self.__width/self.__grid)
                self.__h_grid = math.ceil(self.__heigth/self.__grid)
                self.__my_map = np.zeros(
                    (self.__h_grid, self.__w_grid), dtype='uint8')
                self.__my_map[self.__my_map == 0] = 255
                self.__draw_barriers()
                self.__needExpansionGrid = math.ceil(
                    (self.__robot_size-self.__grid)/2/self.__grid)
                if self.__needExpansionGrid < 0:
                    self.__needExpansionGrid = 0
                self.__expanded = self.__expand_map(self.__needExpansionGrid)
                self.__my_map[self.__expanded[0], self.__expanded[1]] = 0
            except Exception as _:
                print("地图格式错误")
                exit(0)
        else:
            print("地图格式错误")
            exit(0)

    def get_start_point(self):
        return [self.__start_point[0], self.__start_point[1]]

    def get_end_point(self):
        return [self.__end_point[0], self.__end_point[1]]

    def set_end_point(self, end):
        self.__end_point[0] = end[0]
        self.__end_point[1] = end[1]
        del self.__visual_graph
        del self.__visual_points

    def set_start_point(self, start):
        self.__start_point[0] = start[0]
        self.__start_point[1] = start[1]
        del self.__visual_graph
        del self.__visual_points

    def real_to_grid(self, point):
        """实际坐标 -> 栅格坐标"""
        point_x = int(point[0]/self.__grid)
        point_y = int(point[1]/self.__grid)
        if point_x >= self.__my_map.shape[0]:
            point_x = point_x - 1
        if point_y >= self.__my_map.shape[1]:
            point_y = point_y - 1
        return [point_x, point_y]

    def grid_to_real(self, point):
        """栅格坐标 -> 实际坐标"""
        return [point[0]*self.__grid+self.__grid/2, point[1]*self.__grid+self.__grid/2]

    def __fillHole(self):
        """填充有线条绘制的障碍"""
        fillingQueue = [[0, 0]]
        filledSet = set()
        while len(fillingQueue) > 0:
            [x, y] = fillingQueue.pop()
            filledSet.add((x, y))
            if (x >= 0 and x < self.__my_map.shape[0] and
                    y >= 0 and y < self.__my_map.shape[1] and self.__my_map[x, y] == 255):
                self.__my_map[x, y] = 1
                if (x+1, y) not in filledSet:
                    fillingQueue.insert(0, [x+1, y])
                if (x-1, y) not in filledSet:
                    fillingQueue.insert(0, [x-1, y])
                if (x, y+1) not in filledSet:
                    fillingQueue.insert(0, [x, y+1])
                if (x, y-1) not in filledSet:
                    fillingQueue.insert(0, [x, y-1])
        self.__my_map[self.__my_map == 255] = 0
        self.__my_map[self.__my_map == 1] = 255

    def __expand_map(self, needExpansionGrid):
        """得到给定膨胀个数的坐标点集"""
        mask = needExpansionGrid + 1
        tmp_map = self.__my_map.copy()
        [x, y] = tmp_map.shape
        for i in range(x):
            for j in range(y):
                if i + mask > x or j + mask > y:
                    continue
                if np.min(self.__my_map[i:i+mask, j:j+mask]) == 0:
                    tmp_map[i:i+mask, j:j+mask] = 100
        tmp_map[self.__my_map == 0] = 0
        return np.where(tmp_map == 100)

    def get_points_from_two_point_line(self, point_1, point_2):
        """得到两个点之间直线上的点"""
        point_1_x, point_1_y, point_2_x, point_2_y = point_1[0], point_1[1], point_2[0], point_2[1]
        if abs(point_1_x-point_2_x) > abs(point_1_y-point_2_y):
            if point_1_x > point_2_x:
                x = np.array(range(point_2_x, point_1_x+1))
            else:
                x = np.array(range(point_1_x, point_2_x+1))
            y = (x-point_1_x)/(point_2_x-point_1_x) * \
                (point_2_y-point_1_y)+point_1_y
        else:
            if point_1_y > point_2_y:
                y = np.array(range(point_2_y, point_1_y+1))
            else:
                y = np.array(range(point_1_y, point_2_y+1))
            x = (y-point_1_y)/(point_2_y-point_1_y) * \
                (point_2_x-point_1_x)+point_1_x
        x = np.around(x)
        y = np.around(y)
        x = x.astype(np.int32)
        y = y.astype(np.int32)
        return [x, y]

    def __draw_line(self, point_1_data, point_2_data):
        """给定两个实际坐标点在栅格地图上绘制线条，只能绘制直线"""
        point_1, point_2 = [point_1_data['pointX'], point_1_data['pointY']], [
            point_2_data['pointX'], point_2_data['pointY']]
        point_1_x, point_1_y = self.real_to_grid(point_1)
        point_2_x, point_2_y = self.real_to_grid(point_2)
        if point_1_data['lineType'] == 'straight':
            points = self.get_points_from_two_point_line(
                [point_1_x, point_1_y], [point_2_x, point_2_y])
            self.__my_map[points[0], points[1]] = 0
        elif point_1_data['lineType'] == 'curve':
            pass
        else:
            raise KeyError

    def __draw_barriers(self):
        """绘制障碍"""
        if self.__type == 'custom map':
            for barrier in self.__barriers:
                for i in range(len(barrier)):
                    self.__draw_line(barrier[i], barrier[(i+1) % len(barrier)])
        elif self.__type == 'random map':
            wall_width = math.ceil(
                (self.__blank_size + 2*self.__wall_thickness)/self.__grid)
            wall_heigth = math.ceil(self.__wall_thickness/self.__grid)
            for i in range(len(self.__horizontall_wall)):
                for j in range(len(self.__horizontall_wall[i])):
                    if self.__horizontall_wall[i][j] == 0:
                        continue
                    x = math.ceil((self.__border + self.__blank_size*(i+1) +
                                   self.__wall_thickness*i)/self.__grid)
                    y = math.ceil((self.__border + self.__blank_size*j +
                                   self.__wall_thickness*(j-1))/self.__grid)
                    self.__my_map[x:x+wall_heigth, y:y+wall_width] = 0
            for i in range(len(self.__vertical_wall)):
                for j in range(len(self.__vertical_wall[i])):
                    if self.__vertical_wall[i][j] == 0:
                        continue
                    x = math.ceil((self.__border + self.__blank_size*j +
                                   self.__wall_thickness*(j-1))/self.__grid)
                    y = math.ceil((self.__border + self.__blank_size*(i+1) +
                                   self.__wall_thickness*i)/self.__grid)
                    self.__my_map[x:x+wall_width, y:y+wall_heigth] = 0
            pos = math.ceil(
                (self.__border-self.__wall_thickness)/self.__grid)
            pos_left_top = [pos, pos]
            heigth = math.ceil((self.__heigth - 2*self.__border +
                                2*self.__wall_thickness)/self.__grid)
            width = math.ceil((self.__width - 2*self.__border +
                               2*self.__wall_thickness)/self.__grid)
            self.__my_map[pos_left_top[0]:pos_left_top[0]+heigth,
                          pos_left_top[1]:pos_left_top[1]+wall_heigth] = 0
            self.__my_map[pos_left_top[0]:pos_left_top[0]+wall_heigth,
                          pos_left_top[1]+wall_heigth:pos_left_top[1]+width] = 0
            pos_right_top = [pos, pos + width-wall_heigth]
            self.__my_map[pos_right_top[0]:pos_right_top[0]+heigth,
                          pos_right_top[1]:pos_right_top[1]+wall_heigth] = 0
            pos_left_bottom = [pos + heigth-wall_heigth, pos]
            self.__my_map[pos_left_bottom[0]:pos_left_bottom[0]+wall_heigth,
                          pos_left_bottom[1]:pos_left_bottom[1]+width] = 0

    def __get_contours_right_bottom_point(self, open_set, contour_order: ContourOrder):
        n = 0
        right_bottom_point = ()
        current_point = ()
        for point in open_set:
            if point[0] * self.__my_map.shape[0] + point[1] > n:
                n = point[0] * self.__my_map.shape[0] + point[1]
                right_bottom_point = point
        if contour_order == ContourOrder.Clockwise:
            current_point = (right_bottom_point[0]-1, right_bottom_point[1])
        else:
            current_point = (right_bottom_point[0], right_bottom_point[1]-1)
        return right_bottom_point, current_point

    def __get_next_contour_point(self, open_set, current_point):
        if (current_point[0]+1, current_point[1]) in open_set:
            return (current_point[0]+1, current_point[1])
        if (current_point[0], current_point[1]+1) in open_set:
            return (current_point[0], current_point[1]+1)
        if (current_point[0]-1, current_point[1]) in open_set:
            return (current_point[0]-1, current_point[1])
        if (current_point[0], current_point[1]-1) in open_set:
            return (current_point[0], current_point[1]-1)
        return None

    def __get_contours_points(self, contour_order: ContourOrder):
        """得到所有障碍轮廓点"""
        contours_points = self.__expand_map(1)
        open_set = set()
        contours = []
        for i in range(len(contours_points[0])):
            open_set.add((contours_points[0][i], contours_points[1][i]))
        while True:
            right_bottom_point, current_point = self.__get_contours_right_bottom_point(
                open_set, contour_order)
            open_set.remove(right_bottom_point)
            open_set.remove(current_point)
            contour = [right_bottom_point, current_point]
            while True:
                current_point = self.__get_next_contour_point(
                    open_set, current_point)
                if current_point is None:
                    contours.append(contour.copy())
                    contour.clear()
                    break
                contour.append(current_point)
                open_set.remove(current_point)
            if len(open_set) == 0:
                break
        return contours

    def get_visual_points(self):
        """得到障碍物可视点"""
        try:
            self.__visual_points
        except:
            contours = self.__get_contours_points(ContourOrder.Clockwise)
            visual_points = []
            for contour in contours:
                point_1 = 0
                for i in range(1, len(contour)+2):
                    i = i % len(contour)
                    if not self.is_visible(contour[point_1], contour[i]):
                        point_1 = (i-1) % len(contour)
                        visual_points.append([int(contour[(i-1) % len(contour)][0]),
                                              int(contour[(i-1) % len(contour)][1])])
            start_point = self.real_to_grid(self.get_start_point())
            end_point = self.real_to_grid(self.get_end_point())
            visual_points.append(end_point)
            visual_points.insert(0, start_point)
            self.__visual_points = visual_points
        return self.__visual_points.copy()

    def get_visual_graph(self):
        """计算可视点间距离"""
        try:
            self.__visual_graph
        except:
            self.get_visual_points()
            len_visual_points = len(self.__visual_points)
            self.__visual_graph = np.zeros(
                (len_visual_points, len_visual_points))
            for i in range(len_visual_points):
                for j in range(i, len_visual_points):
                    if self.__visual_points[i] == self.__visual_points[j]:
                        self.__visual_graph[i, j] = 0
                    elif self.is_visible(self.__visual_points[i], self.__visual_points[j]):
                        self.__visual_graph[i, j] = pow(pow((self.__visual_points[i][0]-self.__visual_points[j][0])*self.__grid, 2) +
                                                        pow((self.__visual_points[i][1]-self.__visual_points[j][1])*self.__grid, 2), 0.5)
                    else:
                        self.__visual_graph[i, j] = -1
                    self.__visual_graph[j, i] = self.__visual_graph[i, j]
        return self.__visual_graph

    def is_visible(self, point_1, point_2):
        """判断在膨胀过地图上，检查两个点是否可视"""
        points = self.get_points_from_two_point_line(point_1, point_2)
        if np.min(self.__my_map[points[0], points[1]]) == 0:
            return False
        return True

    def save_route_path(self, save_path, points):
        try:
            real_points = [self.get_start_point()]
            for i in range(1, len(points)-1):
                real_points.append(
                    self.grid_to_real(points[i]))
            real_points.append(self.get_end_point())
            tmp_json = json.dumps(real_points)
            f = open(save_path, 'w')
            f.write(tmp_json)
            f.close()
        except:
            print('请运行规划函数')
            exit(1)

    def calculate_path_distance(self, points):
        """计算规划路径长度"""
        if points is None:
            return None
        path = 0
        real_points = [self.get_start_point()]
        for i in range(1, len(points)-1):
            real_points.append(
                self.grid_to_real(points[i]))
        for i in range(len(real_points)-1):
            path = path + pow(pow(real_points[i][0]-real_points[i+1][0], 2) +
                              pow(real_points[i][1]-real_points[i+1][1], 2), 0.5)
        return path

    def optimising_path(self, points):
        """优化路径"""
        current_point = points[0]
        necessary_points = [current_point]
        i = 0
        while True:
            tmp_i = 0
            tmp_point = []
            for j in range(i + 1, len(points)):
                if self.is_visible(current_point, points[j]):
                    tmp_point = points[j]
                    tmp_i = j
            current_point = tmp_point
            i = tmp_i
            necessary_points.append(current_point)
            if necessary_points[-1] == points[-1]:
                break
        return necessary_points


if __name__ == "__main__":
    my_map = Map(sys.argv[1])
    result = dict()
    result['visual_points'] = my_map.get_visual_points()
    result['visual_graph'] = my_map.get_visual_graph().tolist()
    str = json.dumps(result)
    print(str)
